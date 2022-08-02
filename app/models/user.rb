class User < ApplicationRecord
  attr_accessor :remember_token

  validates :email, presence: true,
            length: {minium: Settings.user.email_min,
                     maximum: Settings.user.email_max},
            format: {with: Settings.user.email_pattern},
            uniqueness: {case_sensitive: false}

  validates :name, presence: true,
            length: {maximum: Settings.user.name_max}

  has_secure_password

  validates :password, presence: true,
            length: {minimum: Settings.user.password_min},
            allow_nil: true

  before_save :downcase_email, :standardize_name

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create(string, cost: cost)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    @remember_token = User.new_token
    update_attribute :remember_digest, User.digest(@remember_token)
  end

  def authenticated? remember_token
    return false if remember_digest.blank?

    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  private

  def downcase_email
    email.downcase!
  end

  def standardize_name
    name.strip!
  end
end
