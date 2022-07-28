class User < ApplicationRecord
  validates :email, presence: true,
            length: {minium: Settings.user.email_min,
                     maximum: Settings.user.email_max},
            format: {with: Settings.user.email_pattern},
            uniqueness: {case_sensitive: false}

  validates :name, presence: true,
            length: {maximum: Settings.user.name_max}

  has_secure_password

  before_save :downcase_email, :standardize_name

  private

  def downcase_email
    email.downcase!
  end

  def standardize_name
    name.strip!
  end
end
