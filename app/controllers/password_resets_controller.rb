class PasswordResetsController < ApplicationController
  before_action :find_by_email, :valid_user, :check_expiration,
                only: [:edit, :update]

  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t ".email_sent"
      redirect_to root_url
    else
      flash[:info] = t ".send_failed"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, t(".cant_mt"))
      render :edit
    elsif @user.update(user_params)
      log_in @user
      flash[:success] = t ".reset"
      redirect_to @user
    else
      flash[:danger] = t ".try_again"
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def find_by_email
    @user = User.find_by email: params[:email].downcase
    return if @user

    flash[:danger] = t ".email_not_found"
    redirect_to new_password_reset_path
  end

  def valid_user
    return if @user.activated? && @user.authenticated?(:reset, params[:id])

    flash[:danger] = t ".invalid_link"
    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t ".expired"
    redirect_to new_password_reset_url
  end
end
