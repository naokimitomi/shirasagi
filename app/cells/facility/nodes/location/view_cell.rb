# coding: utf-8
module Facility::Nodes::Location
  class ViewCell < Cell::Rails
    include Cms::NodeFilter::ViewCell
    helper Cms::ListHelper

    public
      def index
        @items = Facility::Node::Page.site(@cur_site).public.
          in(location_ids: @cur_node.id).
          order_by(@cur_node.sort_hash).
          page(params[:page]).
          per(@cur_node.limit)

        @items.empty? ? "" : render
      end
  end
end
