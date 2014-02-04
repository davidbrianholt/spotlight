module Spotlight
  class AboutPagesController < PagesController

    private
    def page_model
      "about_page"
    end
    def cast_page_instance_variable
      if @about_pages
        @pages = @about_pages
      elsif @about_page
        @page = @about_page
      end
    end
  end
end