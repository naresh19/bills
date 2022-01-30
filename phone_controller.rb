class PhoneController < ActionController::Base
  
  require 'csv'
    require 'faraday'

  MONTHS = [nil] + %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
  START_YEAR = 2021
  MONTHLY_RENTAL = 6498.00
  ONE_TIME_CHARGE = 0.00
  # USAGE_MIN = 70000
  # USAGE_MAX = 99900
  RELATIONSHIP_NUM = 4523985401
  BILL_NUM_BASE = 289300000
  BILL_NUM_RAND_MIN = 10000
  BILL_NUM_RAND_MAX = 99999
  BILL_NUM_RAND_DIFF = (BILL_NUM_RAND_MAX - BILL_NUM_RAND_MIN)/12
  USAGE = 0.00
  TAX =  ((MONTHLY_RENTAL + USAGE + ONE_TIME_CHARGE) * 0.18).round(2)
  TOTAL = (MONTHLY_RENTAL + USAGE + ONE_TIME_CHARGE  + TAX). round(2)

  NAME = "Mr NARESH KUMAR SHERWAL"
  ADDRESS = {
    line1: "B-200/3, Birla Farm",
    line2: "Chhattarpur Extension",
    city: "New Delhi 110074",
    state: "Delhi",
    landmark: "Nanda hospital"
  }
    

  def index
    start_month = params[:start_month]&.to_i || 4
    end_month =   start_month + 1
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
              address: ADDRESS,
              name: NAME,
              phone: "01126806785",
              rel_no: RELATIONSHIP_NUM,
             bill_no: BILL_NUM_BASE + bill,
             bill_day: 5,
         start_month: start_month,
           end_month: end_month,
      monthly_rental: MONTHLY_RENTAL.to_s + '0',
            one_time: ONE_TIME_CHARGE.to_s,
               total: TOTAL.to_s.ljust(7, '0'),
               usage: USAGE,
                 tax: TAX.to_s.  ljust(6, '0')
    }
    # render :nothing => true, :status => 200, :content_type => 'text/html'
    # render "phone"
    if params[:type] == 'internet'
      @data.merge({})
    end

    respond_to do |format|
      if params[:type] == 'internet'
        format.html {render 'internet'}
      else
        format.html {render 'phone'}
      end
      format.json {render json: @data.to_json}
    end

  end


  def fuel
    url = "http://www.gnr8tr.online/pos_petrol_diesel_receipt_india_v1"

    addresses = [
        ["Khasra No 76, Mehrauli-Gurgaon Rd", "New Delhi"],
        ["Mehrauli-Gurgaon Rd, Sikanderpur, Gurugram", "Haryana"],
        ["Sector 52A, Gurugram", "Haryana"],
        ["Saket District Centre, Pushp Vihar", "New Delhi"],
      ]

    month_fuel_price = {
      "4" => 80.77,
      "5" => 82.77,
      "6" => 86.28,
      "7" => 89.42,
      "8" => 89.93,
      "9" => 88.66,
      "10" =>  93.18,
      "11" =>  86.71,
      "12" =>  86.71,
      "1" => 86.71,
      "2" => 86.71,
      "3" => 86.71
    }

    max_petrol = 60


    params = HashWithIndifferentAccess.new(
      {
        vehicle_number: "DL2CAQ4562",
        datepicker1: Date.parse('01-03-2021'),
        fuel_rate: "90",
        address: "B-200/3, chhattarpur extn.",
        citownvill: "new delhi",
        cities: "1 SGM",
        pay_mode: "CASH",
        amt_paid: 1222,
        fuel_type: "DIESEL",
        email_id: "naresh.sherwal@gmail.com"
      }
    )

    a = []
    while(params["datepicker1"] < Date.parse("01-04-2022")) do

      params["fuel_rate"]  = (month_fuel_price[params["datepicker1"].month.to_s] + rand(0.1)).round(2)
      params['address'],params['citownvill'] = addresses.sample
      params["amt_paid"] = ([(40+rand(21)) , max_petrol].min * params["fuel_rate"]).round(2)

      new_params = params.dup
      new_params["datepicker1"] = new_params["datepicker1"].to_s+ " #{rand(8..20).to_s.rjust(2, '0')}:#{rand(0..59)}"
      a.push(new_params)

      puts new_params.select{|x,y| ["datepicker1", "fuel_rate", "amt_paid"].include?(x)}

      params["datepicker1"] += (7+rand(7)).days

    end

    a.each do |new_params|
      conn = Faraday.new do |c|
        c.request :url_encoded
        c.adapter Faraday::Adapter::NetHttp
      end
      conn.post(url, new_params)
      sleep 1

    end
    render json: { amt_sum: a.map{|x| x[:amt_paid]}.sum, summary: a.map{|x| [x[:datepicker1], x[:amt_paid]]},data: a}
    puts " - done\n\n"

  end
end
