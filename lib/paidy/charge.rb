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
      @amount = nil
    end

    attr_reader :id, :capture_id, :amount

    def capture
      res = Paidy.request(:post, "#{base_path}/captures", {}, {})
      @capture_id = res['captures'][0]['id']

      self
    end

    def close
      res = Paidy.request(:post, "#{base_path}/close", {}, {})

      self
    end

    def refund(amount: nil, refund_reason: nil)
      params = { capture_id: capture_id }
      params[:amount] = amount if amount.present?
      params[:reason] = refund_reason if refund_reason.present?

      res = Paidy.request(:post, "#{base_path}/refunds", params, {})

      self
    end

    def refund_or_close(amount: nil, refund_reason: nil)
      if capture_id.nil?
        close
      else
        refund(amount: amount, refund_reason: refund_reason)
      end
    end

    def refresh
      res = Paidy.request(:get, "payments/#{id}")

      @amount = res['amount']

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
