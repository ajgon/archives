class AdminBootstrap::Plugins::StatePlugin < AdminBootstrap::Plugins::Base

  STATES = {
      :US => {
          :Alabama => 'AL',
          :Alaska => 'AK',
          :Arizona => 'AZ',
          :Arkansas => 'AR',
          :California => 'CA',
          :Colorado => 'CO',
          :Connecticut => 'CT',
          :Delaware => 'DE',
          :'District of Columbia' => 'DC',
          :Florida => 'FL',
          :Georgia => 'GA',
          :Hawaii => 'HI',
          :Idaho => 'ID',
          :Illinois => 'IL',
          :Indiana => 'IN',
          :Iowa => 'IA',
          :Kansas => 'KS',
          :Kentucky => 'KY',
          :Louisiana => 'LA',
          :Maine => 'ME',
          :Maryland => 'MD',
          :Massachusetts => 'MA',
          :Michigan => 'MI',
          :Minnesota => 'MN',
          :Mississippi => 'MS',
          :Missouri => 'MO',
          :Montana => 'MT',
          :Nebraska => 'NE',
          :Nevada => 'NV',
          :'New Hampshire' => 'NH',
          :'New Jersey' => 'NJ',
          :'New Mexico' => 'NM',
          :'New York' => 'NY',
          :'North Carolina' => 'NC',
          :'North Dakota' => 'ND',
          :Ohio => 'OH',
          :Oklahoma => 'OK',
          :Oregon => 'OR',
          :Pennsylvania => 'PA',
          :'Puerto Rico' => 'PR',
          :'Rhode Island' => 'RI',
          :'South Carolina' => 'SC',
          :'South Dakota' => 'SD',
          :Tennessee => 'TN',
          :Texas => 'TX',
          :Utah => 'UT',
          :Vermont => 'VT',
          :Virginia => 'VA',
          :Washington => 'WA',
          :'West Virginia' => 'WV',
          :Wisconsin => 'WI',
          :Wyoming => 'WY'
      },
      :CA => {
          :Alberta => 'AB',
          :'British Columbia' => 'BC',
          :Manitoba => 'MB',
          :'New Brunswick' => 'NB',
          :'Newfoundland and Labrador' => 'NL',
          :'Northwest Territories' => 'NT',
          :'Nova Scotia' => 'NS',
          :Nunavut => 'NU',
          :Ontario => 'ON',
          :'Prince Edward Island' => 'PE',
          :Quebec => 'QC',
          :Saskatchewan => 'SK',
          :Yukon => 'YT'
      }
  }

  option :state do |value|
    if STATES.keys.include?(value.to_s.upcase.to_sym)
      collection = STATES[value.to_s.upcase.to_sym]
    else
      collection = STATES.values.inject(:merge)
    end
    formtastic_parameters(:as => :select, :collection => collection) if value
  end

end
