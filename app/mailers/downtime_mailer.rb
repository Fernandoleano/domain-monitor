class DowntimeMailer < ApplicationMailer
  default from: "alerts@domainmonitor.com"

  def down_alert(user, site)
    @user = user
    @site = site
    mail(to: @user.email_address, subject: "🔴 Alert: #{@site.name} is DOWN")
  end

  def up_alert(user, site)
    @user = user
    @site = site
    mail(to: @user.email_address, subject: "🟢 Recovered: #{@site.name} is back UP")
  end
end
