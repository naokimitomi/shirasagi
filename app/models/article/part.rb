module Article::Part
  class Page
    include Cms::Model::Part
    include Event::Addon::PageList
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "article/page") }
  end

  class PageNavi
    include Cms::Model::Part
    include Cms::Addon::Release
    include Cms::Addon::GroupPermission
    include History::Addon::Backup

    default_scope ->{ where(route: "article/page_navi") }
  end
end
