module Paidy
  class Charge
    class << self
      def create(params)
        res = Paidy.request(:post, 'payments', params, {})

        self.new(res['id'])
      end

      def retrieve(id)
        instance = self.new(id)
        instance.refresh

        instance
      end
    end

    def initialize(id)
      @id = id
      @capture_id = nil
    end

    attr_reader :id, :capture_id, :status

    def capture
      res = Paidy.request(:post, "#{base_path}/captures", {}, {})
      @capture_id = res['captures'][0]['id']

      self
    end

    def close
      res = Paidy.request(:post, "#{base_path}/close", {}, {})

      self
    end

    def refund
      res = Paidy.request(:post, "#{base_path}/refund", { capture_id: capture_id }, {})

      self
    end

    def refund_or_close
      if capture_id.nil?
        close
      else
        refund
      end
    end

    def refresh
      res = Paidy.request(:get, "payments/#{id}")

      if res['status'] == 'closed' && res['captures'].present?
        @capture_id = res['captures'][0]['id']
      end
    end

    private

    def base_path
      "payments/#{id}"
    end
  end
end
