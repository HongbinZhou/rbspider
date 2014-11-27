require "erb"
require "./lib/my_day_db.rb"
require "./lib/user.rb"
require "./lib/task.rb"

class NewsController
  NewsDB::connect_db

  def task_create(u)
    @user = User.find_by(name: user_name, email: user_email)
    if !@user
      @user = User.create(name: user_name, email: user_email)
      @user_creation_status = "SUCCESS"
    else
      @user_creation_status = "INUSE"
    end
    render_user_create_json
  end

  
  def my_initialize(user_name, user_email)
    @user = User.find_by(name: user_name, email: user_email)
    if !user
      @user = User.create(name: user_name, email: user_email) 
      @user_creation_status = "Creation Success"
    else
      @user_creation_status = "Already Meer"
    end
    @user_deletion_status = "Still Meer"
  end

  def destroy
    @user.destroy
    @user_deletion_status = "Already Deleted"
  end

  def user_task_update(task_name, new_task_status)
    task = @user.tasks.find_by(name: task_name)
    if task
      task.status = new_task_status
      "#{task_name} status update to #{new_task_status}"
    else
      @user.tasks.create(name: task_name, status: new_task_status)
      "#{task_name} created with status #{new_task_status}"
    end
  end

  public
  def render_user_delete_terminal
    render = ERB.new(File.read("./view/user_deletion.tm.erb"))
    render.result(binding)
  end

  def render_user_delete_json
  end
  # ++
  # actually this render user creation html is not neccessary
  # because Mee have not enable user registeration from web page yet
  # only from Mee command line client
  # ++
  def render_user_create_html
    render = ERB.new(File.read("./view/user_creation.html.erb"))
    render.result(binding)
  end

  def render_user_create_terminal
    render = ERB.new(File.read("./view/user_creation.tm.erb"), 0, ">")
    render.result(binding)
  end

  def render_user_create_json
    render = ERB.new(File.read("./view/user_creation_json.erb"))
    render.result(binding)
  end

  def render_user_task_list_html
    render = ERB.new(File.read("./view/user_task_list.html.erb"))
    render.result(binding)
  end

  def render_user_task_list_terminal
    render = ERB.new(File.read("./view/user_task_list.tm.erb"), 0, ">")
    render.result(binding)
  end

  def render_user_task_list_json
    @user.tasks.to_json
  end
end
