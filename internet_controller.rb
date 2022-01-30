class InternetController < ActionController::Base
  # def heartbeat
  #   render :nothing => true, :status => 200, :content_type => 'text/html'
  # end

  MONTHS = [nil] + %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
  START_YEAR = 2020
  MONTHLY_RENTAL = 1019.5
  ONE_TIME_CHARGE = 218.38
  # USAGE_MIN = 70000
  # USAGE_MAX = 99900
  RELATIONSHIP_NUM = 1235621904
  BILL_NUM_BASE = 796100000
  BILL_NUM_RAND_MIN = 10000
  BILL_NUM_RAND_MAX = 99999
  BILL_NUM_RAND_DIFF = (BILL_NUM_RAND_MAX - BILL_NUM_RAND_MIN)/12
  USAGE = 2999.00
  TAX =  ((MONTHLY_RENTAL + USAGE + ONE_TIME_CHARGE) * 0.18).round(2)
  TOTAL = (MONTHLY_RENTAL + USAGE + ONE_TIME_CHARGE  + TAX). round(2)

  def index
    start_month = params[:start_month].to_i || 4
    end_month =    + 1
    if start_month < 3
      year = START_YEAR + 1
    else
      year = START_YEAR
    end

    # usage = (99900 / 100.to_f).round(2)
    # tax = ((MONTHLY_RENTAL + usage + ONE_TIME_CHARGE) * 0.167).round(2)
    # total = (MONTHLY_RENTAL + usage + ONE_TIME_CHARGE + tax).round(2)

    # total_words = total / 1000

    bill_offset = ( (start_month > 3) ? (start_month-3) : (start_month+9) ) - 1
    min = BILL_NUM_RAND_MIN + (bill_offset * BILL_NUM_RAND_DIFF)
    bill = rand(min..(min+BILL_NUM_RAND_DIFF))

    start_month = "#{MONTHS[start_month]}-#{year}"
    if end_month == 13
      end_month = 1
      year = START_YEAR + 1
    end
    end_month = "#{MONTHS[end_month]}-#{year}"

    @data = {
              rel_no: RELATIONSHIP_NUM,
             bill_no: BILL_NUM_BASE + bill,
         start_month: start_month,
           end_month: end_month,
      monthly_rental: MONTHLY_RENTAL.to_s + '0',
            one_time: ONE_TIME_CHARGE.to_s,
               total: TOTAL.to_s.ljust(7, '0'),
               usage: USAGE.to_s.ljust(6, '0'),
                 tax: TAX.to_s.  ljust(6, '0')
    }
    # render :nothing => true, :status => 200, :content_type => 'text/html'
    render "internet"
  end
end
