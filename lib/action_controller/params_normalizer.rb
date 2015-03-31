module ActionController
  module ParamsNormalizer
    extend ActiveSupport::Concern
    require 'mutex_m'

    def process_action(*args)
      normalized_keys = request.request_parameters.keys
      normalized_keys.each do |k|
        request.request_parameters[k.underscore] = request.request_parameters[k]
        request.request_parameters.delete(k) if k != k.underscore
      end
      super
    end
  end
end