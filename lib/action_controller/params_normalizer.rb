module ActionController
  module ParamsNormalizer
    extend ActiveSupport::Concern
    require 'mutex_m'

    def normalize(hash)
      normalized_keys = hash.keys
      normalized_keys.each do |k|
        normalized_param = hash[k.underscore] = hash[k]
        hash.delete(k) if k != k.underscore
        if normalized_param.kind_of?(ActiveSupport::HashWithIndifferentAccess)
          normalize(normalized_param)
        elsif normalized_param.kind_of?(Array)
          normalized_param.each do |param|
            if param.kind_of?(ActiveSupport::HashWithIndifferentAccess)
              normalize(param)
            end
          end
        end

      end
    end

    def process_action(*args)
      normalize(request.request_parameters)

      super
    end
  end
end