class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token

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
  before_create :create_activation_digest

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

  def authenticated? attr, token
    digest = send("#{attr}_digest")
    return false if digest.blank?

    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute :remember_digest, nil
  end

  def create_activation_digest
    @activation_token = User.new_token
    self.activation_digest = User.digest(@activation_token)
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    @reset_token = User.new_token
    update_columns reset_digest: User.digest(@reset_token),
                   reset_sent_at: Time.zone.now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < Settings.reset_exp.hours.ago
  end

  private

  def downcase_email
    email.downcase!
  end

  def standardize_name
    name.strip!
  end
end
