class WorksController < ApplicationController
  before_action :authenticate_user
  before_action :set_work, only: [:show, :update, :destroy, :bind_participants, :unbound_participants, :bind_tags, :unbound_tags]
  @@includes = [:users, :tags, :user]
  # GET /works
  def index
    @works = Work.all
    json_response(@works, :ok, @@includes)
  end

  # POST /works
  def create
    @work = Work.create!(work_params)
    p @work.to_json(:include => @@includes)
    ActionCable.server.broadcast "works", {
        work: @work.to_json(:include => @@includes),
        added: true,
        from_stream: "works",
    }
    json_response(@work, :created)
  end

  # GET /works/:id
  def show
    json_response(@work, :ok, @@includes)
  end

  # PUT /works/:id
  def update
    if is_current_user(@work.user.id)
      @work.update(work_params)
      json_response(@work, :ok, @@includes)
    else
      head :forbidden
    end
  end

  # DELETE /works/:id
  def destroy
    if is_current_user(@work.user.id)
      @work.destroy
      ActionCable.server.broadcast "works", {
          work: @work.to_json(:include => @@includes),
          from_stream: "works",
      }
      json_response(@work)
    else
      head :forbidden
    end
  end

  # POST /works/:id/users
  def bind_participants
    @participant = User.find(params[:user_id])
    @work.users << @participant
    if @work.save
      if @work.user_id != @participant.id
        ActionCable.server.broadcast "works_#{@work.user_id}", {
            work: @work,
            user: @participant,
            subscribe: true,
            from_stream: "works_#{@work.user_id}",
        }
      end
      create_notification(true, @work, @participant)
      json_response(@work, :ok, @@includes)
    end
  end

  # DELETE /works/:id/users/:user_id
  def unbound_participants
    @user_id = params[:user_id].to_i
    if is_current_user(@user_id)
      @user = @work.users.find(@user_id)
      @work.users.destroy(@user)
        ActionCable.server.broadcast "works_#{@work.user_id}", {
            work: @work,
            user: @user,
            subscribe: false,
            from_stream: "works_#{@work.user_id}",
        }
        create_notification(false, @work, @user)
      json_response(@work, :ok, @@includes)
    else
      head :forbidden
    end
  end

  def bind_tags
    if is_current_user(@work.user.id)
      @tags = Tag.find(params[:tag_id])
      @work.tags << @tags

      ActionCable.server.broadcast "works", {
          work: @work.to_json(:include => @@includes),
          updated: true,
          from_stream: "works"
      }
      @tags.each do |tag|
        ActionCable.server.broadcast "tags_#{tag[:name]}", {
            work: @work,
            tag: tag,
            from_stream: "tags_#{tag[:name]}",
        }
        create_tag_notifications(@work, tag)
      end
      json_response(@work, :ok, @@includes)


    else
      head :forbidden
    end
  end

  def unbound_tags
    if is_current_user(@work.user.id)
      @tag = @work.tags.find(params[:tag_id])
      @work.tags.destroy(@tag)
      ActionCable.server.broadcast "works", {
          work: @work.to_json(:include => @@includes),
          updated: true,
          from_stream: "works"
      }
      json_response(@user, :ok, @@includes)
    else
      head :forbidden
    end
  end

  private

  def work_params
    # whitelist params
    params.permit(:name, :desc, :tag_id, :user_id, :users, :id, :tags)
  end

  def set_work
    @work = Work.find(params[:id])
  end

  def create_tag_notifications(work, tag)
    notifs = Array.new
    title = "A new project (#{work.name}) was created with the tag #{tag.name} that you follow !"
    tag.users.each do | user |
      if user.id != work.user_id
        notif = {
            title: title,
            redirects_to: '/works',
            read: false,
            user_id: user.id
        }
        notifs << notif
      end
    end
    Notification.create(notifs);
  end

  def create_notification(subscribe, work, user)
    if subscribe
      @title = "#{user.pseudo} is participating to your work #{work.name} !"
    else
      @title = "#{user.pseudo} is not participating to your work #{work.name} anymore !"
    end
    @notif = {
        title: @title,
        redirects_to: '/works',
        read: false,
        user_id: work.user_id
    }
    Notification.create!(@notif)
  end
end
