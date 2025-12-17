class SitesController < ApplicationController
  before_action :set_site, only: %i[ show edit update destroy check_now ]
  skip_before_action :verify_authenticity_token, only: [ :create, :lookup ], if: -> { request.format.json? }

  def index
    @sites = Current.user.sites.order(created_at: :desc)

    # Dashboard Commander Metrics
    @total_sites = @sites.count
    @global_uptime = @sites.any? ? @sites.map(&:uptime_percentage).sum / @sites.count : 100
    @avg_latency = @sites.map(&:avg_response_time).sum / (@sites.count.nonzero? || 1)
  end

  def lookup
    @site = Current.user.sites.find_by(url: params[:url])

    if @site
      render json: {
        found: true,
        site: @site,
        last_check: @site.last_check,
        uptime: @site.uptime_percentage,
        avg_latency: @site.avg_response_time
      }
    else
      render json: { found: false }, status: :not_found
    end
  end

  def show
    @checks = @site.checks.order(created_at: :desc).limit(50)
  end

  def new
    @site = Current.user.sites.new
  end

  def edit
  end

  def create
    @site = Current.user.sites.new(site_params)

    respond_to do |format|
      if @site.save
        UrlCheckerJob.perform_later(@site.id)
        format.html { redirect_to site_url(@site), notice: "Site was successfully created." }
        format.json {
          Notification.create(
            user: @site.user,
            title: "#{@site.name.presence || @site.url}",
            body: "Monitoring started.",
            url: site_url(@site),
            params: { 
              favicon_url: "https://www.google.com/s2/favicons?domain=#{@site.url}&sz=128",
              stats: "Interval: #{@site.check_interval}m"
            }
          )
          render json: { status: "created", site: @site }, status: :created
        }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: { status: "error", errors: @site.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @site.update(site_params)
      redirect_to site_url(@site), notice: "Site was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @site.destroy
    redirect_to sites_url, notice: "Site was successfully destroyed."
  end

  def check_now
    UrlCheckerJob.perform_later(@site.id)
    redirect_to site_url(@site), notice: "Check queued."
  end

  private
    def set_site
      @site = Current.user.sites.find(params[:id])
    end

    def site_params
      params.require(:site).permit(:url, :name, :check_interval, :active)
    end
end
