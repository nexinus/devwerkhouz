module ApplicationHelper
  # Returns the route if the named path helper exists, otherwise returns the fallback path.
  # name: symbol like :account_path or :pricing_path
  # fallback: string or path helper (e.g., root_path or '/pricing')
  def safe_path(name, fallback)
    if respond_to?(name)
      send(name)
    else
      fallback
    end
  end
end
