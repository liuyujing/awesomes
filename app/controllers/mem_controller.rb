class MemController < ApplicationController
  before_filter :is_me?,:except=>['login','auth']
  def auth
    _data = request.env["omniauth.auth"] 
    #render json: _data and return

    _provider = params[:provider]
    _para = {
      :provider => _provider,
      :uid => _data['uid']
    }
    _mauth = Mauth.where(_para).first
    
    #注册 /  绑定账号
    if _mauth.nil?
      _mem = current_mem
      if !_mem
        _raw_info = _data['extra']['raw_info']
        _photo = ''
        if _provider == 'github'
          _photo =_raw_info['avatar_url']
        end

        #require 'uuidtools'   
        #_filename =  UUIDTools::UUID.timestamp_create.to_s + '.jpg'
        #upload_remote(_photo,_filename,'mem') 
        _mem = Mem.create({
          :nc => _data['info']['nickname'], 
          #:avatar => _filename,
          :email => _raw_info[:email]
        })


        _mem.mem_info.update_attributes({
          :gender => _data['extra']['gender'],
          :location=> _raw_info['location'],
          :html_url=> _raw_info['html_url'],
          :blog=> _raw_info['blog'],
          :followers=> _raw_info['followers'],
          :following=> _raw_info['following'],
          :github=> _raw_info['login']
        })
      end
      _mem.mauths.create(_para)
      session[:mem] = _mem.id
      
    else 
      session[:mem] = _mauth.mem.id
    end
    #render json: _data and return
    redirect_to session[:login_callback]
  end

  def login
    session[:login_callback] = request.referer
    redirect_to "/auth/#{params[:from]}"
  end

  def index
    @items = data_list_asc @mem.readmes
    @count = @mem.readmes.count
  end

  def comments
    @items = data_list_asc @mem.comments
    @count = @mem.comments.count
  end

  def sync_repo
    require 'rest-client'
    _response = RestClient.get "https://api.github.com/users/#{current_mem.mem_info.github}/repos?page=1&per_page=5"
    _result = JSON.parse(_response.body) 
    MemRepo.where({:mem_id=> current_mem.id}).delete_all
    _result.each do |item|
      current_mem.mem_repos << MemRepo.create({
        :name=> item['name'],
        :html_url=> item['html_url'],
        :description=> item['description'],
        :stargazers_count=> item['stargazers_count']
      })
    end
    redirect_to request.referer
  end
  
end
