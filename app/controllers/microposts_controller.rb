class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach(params[:micropost][:image])
    if @micropost.save
      micropost_save_success
    else
      micropost_save_failure
    end
  end

  def destroy
    if @micropost.destroy
      flash[:success] = t ".success"
    else
      flash[:danger] = t ".failed"
    end
    redirect_to request.referer || root_url
  end

  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    return if @micropost.present?

    flash[:warning] = t ".post_not_found"
    redirect_to root_url
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content, :image)
  end

  def micropost_save_success
    flash[:success] = t ".success"
    redirect_to root_url
  end

  def micropost_save_failure
    flash[:danger] = t ".failed"
    @pagy, @feed_items = pagy(current_user.feed, items: Settings.pagy.items)
    render "static_pages/home"
  end
end
