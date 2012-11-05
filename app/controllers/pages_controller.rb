class PagesController < ApplicationController

	include Mycelial

	before_filter :authenticate_user!, except: [:show, :index]
	before_filter :correct_user, only: [:edit, :update]
	#get the sidebar data from the session user id for the logged in methods
	before_filter :get_sidebar_info, except: [:index, :show, :new, :create]

	def index
		@page = Page.all
	end

	def new 
		@page = Page.new
		#need to check if the user already has a page. if they do then redirect to edit
		if @check = User.find(current_user.id).page
			redirect_to :action => "edit", :id => @check.id, only_path: true
		end
	end

	def show
		#need to get the username from users table and fetch appropriate hacker page based on this. 
		if is_numeric?(params[:id])
			@page = Page.find(params[:id])
		else 
			@page = User.find_by_username(params[:id]).page
		end
		#get the projects for this page from project model. 
	end

	def edit
		#@page is now being retrieved from the mycelial module and the get_sidebar_info method
		#@page = Page.find(params[:id])
		#projects will return an array, since there can be many associated with each page. 

		#this method below now works due to the has_many through association in User. Don't need to use it this way, though. 
		#@projects = User.find(current_user.id).projects

		@projects = Page.find(params[:id]).projects
	end

	def create 
		@page = Page.new(params[:page])
		@page.user_id = current_user.id
		if @page.save
			session[:page_id] = @page.id
			if params[:page][:image].present?
				render 'crop'
			else 
				flash[:success] = "Your page has been created."
				redirect_to @page, only_path: true
			end
		else 
			render 'new'
		end
	end

	def update
		#@page is now being retrieved from the mycelial module and the get_sidebar_info method
		#@page = Page.find(params[:id])
		if @page.update_attributes(params[:page])
      #handle a successful update
      #get rid of this session variable in the update eventually. Need to figure out a way to get this upon login, and also assign it during create. 
      session[:page_id] = @page.id
      if params[:page][:image].present?
				render 'crop'
			else 
      	flash[:success] = "Page updated"
      	redirect_to :action => "edit", :id => params[:id], only_path: true
      end
    else 
      render 'edit'
    end
	end

	private

		def current_user?(user)
			user.id == current_user.id
		end

    def correct_user
    	@user = Page.find(params[:id]).user
    	if @user
      	redirect_to(root_path) unless current_user?(@user)
      else 
      	redirect_to(root_path)
      end
    end

    def is_numeric?(obj) 
   		obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
		end

		#only call this for the signed in methods. When they are editing their page. 
		def get_sidebar_info
			if user_signed_in?
				@page = sidebar_data(current_user.id)
			end
		end
end