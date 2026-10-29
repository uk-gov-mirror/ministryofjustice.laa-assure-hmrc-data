class DefaultQueueNameService
  def self.call
    new.call
  end

  def call
    if Rails.host.uat?
      "default-#{release_name}"
    else
      "default"
    end
  end

private

  # See https://github.com/ministryofjustice/laa-civil-apply-build-and-push/blob/main/action.yml#L62
  # for branch naming conventions
  def release_name
    Rails.configuration.x.status.app_branch
      .downcase
      .squish
      .sub(/\A\w*\//, "")
      .tr_s(" _/[]().", "-")
      .slice(0, 30)
      .delete_suffix("-")
  end
end
