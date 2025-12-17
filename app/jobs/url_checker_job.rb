require "net/http"

class UrlCheckerJob < ApplicationJob
  queue_as :default

  def perform(site_id)
    site = Site.find_by(id: site_id)
    return unless site&.active?

    uri = URI.parse(site.url)
    start_time = Time.current

    begin
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
        request = Net::HTTP::Get.new(uri)
        request["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

        response = http.request(request)
        duration = ((Time.current - start_time) * 1000).to_i
        status_code = response.code.to_i
        # Treat 403 (Forbidden) and 429 (Too Many Requests) as UP because the server is responding.
        success = response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection) || [403, 429].include?(status_code)

        record_check(site, status_code, duration, success)
        update_site_status(site, success)
      end
    rescue StandardError => e
      puts "Check failed for #{site.url}: #{e.message}"
      duration = ((Time.current - start_time) * 1000).to_i
      record_check(site, 0, duration, false)
      site.update(status: "down")
    end

    # Schedule next check
    self.class.set(wait: site.check_interval.minutes).perform_later(site.id)
  end

  private

  def record_check(site, code, duration, success)
    site.checks.create!(
      status_code: code,
      response_time_ms: duration,
      success: success
    )
  end

  def update_site_status(site, success)
    new_status = success ? "up" : "down"
    if site.status != new_status
      site.update(status: new_status)

      if new_status == "down"
        # We need to fetch the last check to get stats; it was just created in record_check
        last_check = site.checks.last 
        
        Notification.create(
          user: site.user,
          title: site.name.presence || site.url,
          body: "Site is DOWN.",
          url: "/sites/#{site.id}",
          params: { 
            favicon_url: "https://www.google.com/s2/favicons?domain=#{site.url}&sz=128",
            stats: "Response: #{last_check&.response_time_ms}ms • Code: #{last_check&.status_code}"
          }
        )
        DowntimeMailer.with(user: site.user, site: site).down_alert.deliver_later
      elsif new_status == "up"
         last_check = site.checks.last
         
         Notification.create(
          user: site.user,
          title: site.name.presence || site.url,
          body: "Site recovered.",
          url: "/sites/#{site.id}",
          params: { 
            favicon_url: "https://www.google.com/s2/favicons?domain=#{site.url}&sz=128",
            stats: "Recovered • Response: #{last_check&.response_time_ms}ms"
          }
        )
         DowntimeMailer.with(user: site.user, site: site).up_alert.deliver_later
      end
    end
  end
end
