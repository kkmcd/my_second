class MoviesController < ApplicationController
before_action :js_authenticate_user!, only: [:like_movie, :create_comment, :destroy_comment, :update_comment]
before_action :authenticate_user!, except: [:index, :show, :search_movie]
before_action :set_movie, only: [:show, :edit, :update, :destroy, :create_comment]  
  # GET /movies
  # GET /movies.json
  def index
    @movies = Movie.page(params[:page])
  @users = User.order(:name).page params[:page]
  end

  # GET /movies/1
  # GET /movies/1.json
  def show
      @user_likes_movie = Like.where(user_id: current_user.id, movie_id: @movie.id).first #where는 객체를 리턴하기 때문에 first를 써야함.
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies
  # POST /movies.json
  def create
    @movie = Movie.new(movie_params)
    @movie.user_id = current_user.id
    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: 'Movie was successfully created.' }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1
  # PATCH/PUT /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: 'Movie was successfully updated.' } #html로 요청이 오면 html로 보내주고
        format.json { render :show, status: :ok, location: @movie } #json으로 요청이 오면 json으로 보내준다.
      else
        format.html { render :edit }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.json
  def destroy
    @movie.destroy
    respond_to do |format|
      format.html { redirect_to movies_url, notice: 'Movie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def like_movie
    p params
    # 현재 유저와 params에 담긴 movie간의 
    # 좋아요 관계를 설정한다. 끗
    
    @like =Like.where(user_id:current_user.id, movie_id:params[:movie_id]).first #where는 리턴이 배열이므로 얘의 첫번째를 찾아줘야함.
    if @like.nil?
      @like = Like.create(user_id: current_user.id, movie_id: params[:movie_id])
    else
      @like.destroy
    end
    # @like.frozen? #삭제됐을경우 삭제되지 못하게 얼어있는다. 삭제된 경우가 좋아요 취소된 경우임. true라면 좋아요 취소 로직을 넣고, 아니면 좋아요가 새로 눌린 경우로 생각하면됨.
    # 만약에 현재 로그인한 유저가 이미 좋아요를 눌렀을 경우
    # 해당 Like 인스턴스 삭제
    # 새로 누른 경우
    # 좋아요 관계 설정
    
  end
  
  
  def create_comment
    @comment = Comment.create(user_id: current_user.id, movie_id: @movie.id, contents: params[:contents])
    #@movie.comments.new(user_id:current_user.id, movie_id: @movie.id)
    
  end

  def destroy_comment
    @comment = Comment.find(params[:comment_id]).destroy()
  end
  
  def update_comment
    @comment = Comment.find(params[:comment_id])
    @comment.update(contents: params[:contents])
  end
  
  def search_movie
    respond_to do |format|
      if params[:q].strip.empty? #빈 공백(스페이스)을 인식하지 못하도록 strip해버림
        format.js {render 'no_content'} # 내가 원하는(action명과 일치하는) 자바스크립트 파일을 보내줄 수 있다고 생각하면 됨.
      else                              # 즉, no_content.js.erb를 찾아서 보내줌.
        @movies = Movie.where("title LIKE ?","#{params[:q]}%") # q의 내용으로 시작하는 결과를 찾음.
        format.js {render 'search_movie'}
      end
    end
  end
  
  def upload_image
    @image = Image.create(image_path: params[:upload][:image])
    render json: @image
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def movie_params
      params.require(:movie).permit(:title, :genre, :director, :actor, :description, :image_path)
    end
end
