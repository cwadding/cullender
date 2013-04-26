class Hash
  def deep_delete(hash)
    hash.each do |key, value|
      if self.has_key?(key)
        if value.is_a?( Hash ) && self[key].is_a?(Hash)
          self[key].deep_delete(value)
        else
          self.delete(key)
        end
      end
    end
  end
end