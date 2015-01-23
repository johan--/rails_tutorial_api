class Api::V1::MicropostsController < Api::V1::BaseController
  def index
    microposts = Micropost.all

    microposts = microposts.where(user_id: params[:user_id]) if params[:user_id]

    if params[:page]
      microposts = microposts.page(params[:page])
      if params[:per_page]
        microposts = microposts.per_page(params[:per_page])
      end
    end

    render(
      json: ActiveModel::ArraySerializer.new(
        microposts,
        each_serializer: Api::V1::MicropostSerializer,
        root: 'microposts',
        meta: meta_attributes(microposts)
      )
    )
  end

  def show
    micropost = Micropost.find_by(id: params[:id])
    return api_error(status: 404) if micropost.nil?
    #authorize micropost

    render json: Api::V1::MicropostSerializer.new(micropost).to_json
  end

  def create
    micropost = Micropost.new(create_params)
    return api_error(status: 422, errors: micropost.errors) unless micropost.valid?

    micropost.save!

    render(
      json: Api::V1::MicropostSerializer.new(micropost).to_json,
      status: 201,
      location: api_v1_micropost_path(micropost.id),
      serializer: Api::V1::MicropostSerializer
    )
  end

  def update
    micropost = Micropost.find_by(id: params[:id])
    return api_error(status: 404) if micropost.nil?
    #authorize micropost

    if !micropost.update_attributes(update_params)
      return api_error(status: 422, errors: micropost.errors)
    end

    render(
      json: Api::V1::MicropostSerializer.new(micropost).to_json,
      status: 200,
      location: api_v1_micropost_path(micropost.id),
      serializer: Api::V1::MicropostSerializer
    )
  end

  def destroy
    micropost = Micropost.find_by(id: params[:id])
    return api_error(status: 404) if micropost.nil?
    #authorize micropost

    if !micropost.destroy
      return api_error(status: 500)
    end

    head status: 204
  end

  private

  def create_params
     params.require(:micropost).permit(
       :content, :picture, :user_id
     )
  end

  def update_params
    create_params
  end
end
