module SectionHelper

  def section_listing(section)
    @section_list = FeedEntry.where(category: section).order(score: :desc).limit(8)
  end

end