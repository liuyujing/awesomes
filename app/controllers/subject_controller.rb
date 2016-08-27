class SubjectController < ApplicationController
  before_action :admin_login,:only=> ["new","update"]
  before_action :subject_lost,:except=> ["new","update"]

  def subject_lost
    @item = Subject.find_by_key params[:key]
  end

  def index
    _query = Repo.where("tag like ?","%#{@item.title}%").order("trend desc")
    @items = {}
    @repo = @item.repo
    data_list(_query).each do |item|
      @items[item.rootyp_zh] = @items[item.rootyp_zh] || {}
      @items[item.rootyp_zh][item.typcd_zh] = @items[item.rootyp_zh][item.typcd_zh] || []
      @items[item.rootyp_zh][item.typcd_zh].push  item
    end
    @count = _query.count
  end

  def new
    @item = Subject.new
  end

  def edit
    render "new"
  end

  def update
    @item = Subject.find_by_id(params[:subject][:id]) || Subject.new
    @item.update_attributes(params.require(:subject).permit(Subject.attribute_names))
    redirect_to "/admin/subjects"
  end

  def admins
    _where = {:typcd=> 'Admins'}
    @items = data_list(Repo.where(_where).order('(stargazers_count + forks_count + subscribers_count) desc'))
    @count = Repo.where(_where).count
  end

  def videos
    @videos = Repo.where('hidetags like ?', '%player%').order('(stargazers_count + forks_count + subscribers_count) desc')
    @bgvideos = Repo.where('hidetags like ?', '%bgvideo%').order('(stargazers_count + forks_count + subscribers_count) desc')
  end

  def editors
    _where = {:typcd=> 'Editor'}
    @items = data_list(Repo.where(_where).order('trend desc'))
    @count = Repo.where(_where).count
  end

end
