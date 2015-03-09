class PageView < ActiveRecord::Base
  belongs_to :user
  belongs_to :real_user, class_name: 'User'

  serialize :parameters, Hash

  scope :api_requests, -> { where(request_format: :json) }
  scope :html_requests, -> { where(request_format: :html) }
  scope :with_controller, -> (controller) { where(controller: controller) }
  scope :with_action, -> (action) { where(action: action) }
  scope :masqueraded, -> { where('page_views.user_id <> page_views.real_user_id AND page_views.user_id IS NOT NULL') }

  def self.strip_files(h)
    h.each_with_object({}) do |(k,v),g|
      g[k] =
        case v
          when Hash
            strip_files(v)
          else
            v.is_a?(ActionDispatch::Http::UploadedFile) ? '' : v
        end
      g
    end
  end

  def masqueraded?
    user_id && real_user_id && user_id != real_user_id
  end
end