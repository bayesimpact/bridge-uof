# Generic helper methods that don't belong in other Helper modules go here.
module ApplicationHelper
  def title(page_title)
    content_for(:title) { page_title }
  end
end
