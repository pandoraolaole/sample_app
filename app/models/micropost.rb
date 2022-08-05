class Micropost < ApplicationRecord
  belongs_to :user
  has_one_attached :image
  validates :user_id, presence: true
  validates :content, presence: true,
            length: {maximum: Settings.post.content_max}
  validates :image, content_type: {in: Settings.post.image.content_types,
                                   message: :valid_format},
            size: {less_than: Settings.post.file_size_limit,
                   message: :file_size_limit}
  scope :newest, ->{order(created_at: :desc)}
  delegate :name, to: :user, prefix: true

  def display_image
    image.variant(
      resize_to_limit: [
        Settings.post.image.width,
        Settings.post.image.height
      ]
    )
  end
end
