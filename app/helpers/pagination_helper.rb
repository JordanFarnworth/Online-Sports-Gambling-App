module PaginationHelper

  MAX_PER_PAGE = 100
  DEFAULT_PER_PAGE = 50

  def pagination_help(p = self.params)
    {
      page: (p[:page] ? p[:page].to_i : 1),
      per_page: [[(p[:per_page] ? p[:per_page].to_i : DEFAULT_PER_PAGE), 1].max, MAX_PER_PAGE].min
    }
  end

  def pagination_json(obj, method = nil, *opts)
    count = obj.count
    p_params = pagination_help
    obj = obj.paginate(p_params)
    obj = self.method(method).call(obj, *opts) if method
    {
      results: obj,
      count: count,
      page: p_params[:page],
      per_page: p_params[:per_page],
      total_pages: (count.to_f / p_params[:per_page].to_f).ceil
    }
  end

  def self.options_hash
    {
      renderer: BootstrapPagination::Rails,
      previous_label: '←',
      next_label: '→',
      inner_window: 2,
      outer_window: 0
    }
  end

  def self.wide_options_hash
    options_hash.merge({
       inner_window: 3,
       outer_window: 2
     })
  end
end