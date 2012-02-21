module PaginationMocking
  def mock_pagination_of ary
    def ary.current_page
      1
    end
    def ary.num_pages
      1
    end
    def ary.limit_value
      1
    end
	def ary.page *args
	  self
	end
    ary
  end
end
