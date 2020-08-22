module PipedriveAppLogger
  def log_info(hash)
    KVPLogFormatter.info(format(hash.merge(class: self.class.to_s)))
  end

  def log_error(hash)
    KVPLogFormatter.error(format(hash.merge(class: self.class.to_s)))
  end

  private

  def format(hash)
    new_hash = {}
    hash.each do |k, v|
      subhash = nil
      if v.respond_to?(:attributes)
        subhash = v.attributes
      elsif v.respond_to?(:to_hash)
        subhash = v.to_hash
      end
      if subhash
        subhash.each do |sk, sv|
          new_hash["#{k}.#{sk}"] = sv
        end
      else
        new_hash[k] = v.to_s
      end
    end
    new_hash
  end
end
