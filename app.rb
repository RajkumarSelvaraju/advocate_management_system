class Advocate
	@@advocates = []
	@@cases = []
	def initialize
		show_option		
	end

	def options
		options = { 
			'1' => 'Add an advocate',
			'2' => 'Add junior advocates',
			'3' => 'Add states for advocates',
			'4' => 'Add cases for advocates',
			'5' => 'Reject a case',
			'6' => 'Display all advocates',
			'7' => 'Display all cases under a state',
			'8' => 'Exit'
		}
	end

	def show_option
		puts "Select an option"
		options.each { |num, text| puts "#{num}. #{text} \n" }
		selected_option
	end

	def get_input
		input = gets.chomp
		if input != ""
			return input
		else
			puts "Please enter value"
		end
	end

	def selected_option
		selected_option = get_input
		if !options.keys.include?(selected_option)
			puts "Please select the above mentioned option."
		else
			if selected_option == '1'
				puts "#{options[selected_option]}:"
				id = get_input	
				unless find_advocate(id)
					puts "Advocate added #{id}"
					@@advocates << {
						id: id,
						practicing_case: [],
						blocklist: [],
						states: [],
						junior: []
					}
					display_advocate(id)
				else
					puts "This Advocate is already Added."
				end
			elsif selected_option == '8'
				return false
			else
				if @@advocates.size <= 0
					puts "Please add a advocate"
				else
					puts "#{options[selected_option]}:"
					case selected_option
					when '2'
						select_senior
					when '3'
						add_state
					when '4'
						add_case('practice')
					when '5'
						add_case('block')
					when '6'
						show_all_advocates
					when '7'
						display_case_by_states
					end
				end				
			end
		end
		show_option
	end

	def advocate(advocate_id)
		@@advocates.find { |advocate| advocate if advocate[:id] == advocate_id }
	end

	def find_advocate(advocate_id)
		@@advocates.find { |advocate| advocate[:id] == advocate_id }
	end

	def find_senior(junior_id)
		@@advocates.find { |advocate| advocate if advocate[:junior] && advocate[:junior].any? { |junior| junior[:junior_id] == junior_id } }
	end

	def find_senior_advocate(junior_id)
		@@advocates.find {|advocate| advocate if advocate[:id] == junior_id && advocate[:junior] && advocate[:junior].size > 0 }
	end

	def display_advocate(advocate_id)
		@advocate = find_senior(advocate_id)
		if @advocate
			show_advocates(@advocate)
		elsif find_advocate(advocate_id)
			@advocate = @@advocates.find { |advocate| advocate if advocate[:id] == advocate_id }
			show_advocates(@advocate)
		end
	end

	def select_senior
		puts "Senior Advocate ID:"
		senior_id = get_input
		senior = find_advocate(senior_id)
		unless senior
			puts "Senior ID is not found."
			select_senior
		end
		if find_senior(senior_id)
			puts "This Advocate is already Junior."
		else
			select_junior(senior_id)
		end
	end

	def select_junior(senior_id)
		puts "Junior Advocate ID:"
		junior_id = get_input
		junior = find_advocate(junior_id)
		unless junior
			puts "Junior ID is not found."
		else
			if find_senior(junior_id)
				puts "This Advocate is already taken as Junior."
			elsif find_senior_advocate(junior_id)
				puts "This Advocate is already taken as Senior."
			else
				@@advocates.map { |advocate|
					if advocate[:id] == senior_id
		  			advocate[:junior] << { junior_id: junior_id }				
					end
				}
				display_advocate(senior_id)
			end			
		end
	end

	def add_state
		puts "Advocate ID:"
		advocate_id = get_input
		advocate = find_advocate(advocate_id)
		if advocate
			puts "Practicing State:"
			state = get_input
			senior = find_senior(advocate_id)
			@advocate = advocate(advocate_id)	
			new_state = true
			if senior && !senior[:states].include?(state)				
				puts "Cannot add #{state} for #{advocate_id}."
				new_state = false
			elsif @advocate && @advocate[:states].map(&:upcase).include?(state.upcase)
				puts "Already Added this #{state} for #{advocate_id}."
				new_state = false
			end
		else
			puts "Advocate not found for this ID #{advocate_id}."
		end
		if new_state
			@@advocates.map { |advocate|
				if advocate[:id] == advocate_id
					advocate[:states] << state				
				end
			}	
			puts "State Added #{state} for #{advocate_id}."
			display_advocate(advocate_id)	
		end
	end

	def add_case(type)
		puts "Advocate ID:"
		advocate_id = get_input
		advocate = find_advocate(advocate_id)
		if advocate
			senior = find_senior(advocate_id)
			@advocate = advocate(advocate_id)
			puts "Case ID:"
			case_id = get_input
			puts "Practicing State:"
			state = get_input
			if type == 'practice' && senior && senior[:blocklist].include?("#{case_id} - #{state}")
				puts "Cannot add #{case_id} case under #{advocate_id}."
			elsif type == 'practice' && @advocate && @advocate[:practicing_case].map(&:upcase).include?("#{case_id} - #{state}".upcase)
				puts "Already Added this Practicing Case #{case_id} - #{state} for #{@advocate[:id]}"
			elsif type == 'block' && @advocate && @advocate[:blocklist].map(&:upcase).include?("#{case_id} - #{state}".upcase)
				puts "Already Added this Block list Case #{case_id} - #{state} for #{@advocate[:id]}"
			else
				@@cases << { type: type, advocate_id: advocate_id, case_id: case_id, state: state }
				@@advocates.map { |advocate|
					if advocate[:id] == advocate_id
						if type == 'practice'
							advocate[:practicing_case] << "#{case_id} - #{state}"
						else
							advocate[:blocklist] << "#{case_id} - #{state}"
						end
					end
				}
				if type == 'practice'
					puts "Case #{case_id} added for #{advocate_id}."	
				else
					puts "Case #{case_id} is added in Block list for #{advocate_id}."
				end
				display_advocate(advocate_id)
			end
		else
			puts "Advocate not found for this ID #{advocate_id}."
		end
	end

	def show_advocates(advocate)
		puts "Display:"
		display_single_advocate(advocate)
	end

	def display_single_advocate(advocate)
		puts "Advocate Name: #{advocate[:id]}"
		puts "Practicing states: #{advocate[:states].join(', ')}" if advocate[:states].size > 0
		puts "Practicing Cases: #{advocate[:practicing_case].join(', ')}" if advocate[:practicing_case].size > 0
		puts "BlockList Cases: #{advocate[:blocklist].join(', ')}" if advocate[:blocklist].size > 0
		advocate[:junior].each { |junior|
			puts "-Advocate Name: #{junior[:junior_id]}"
			puts "-Practicing states: #{find_advocate(junior[:junior_id])[:states].join(', ')}" if find_advocate(junior[:junior_id])[:states].size > 0
		}
		puts "\n"
	end

	def show_all_advocates()
		puts "Advocates:"
		@@advocates.each { |advocate| 
			display_single_advocate(advocate)
		}
	end

	def display_case_by_states
		puts "State Id:"
		state = get_input
		cases = @@cases.map { |adv_cse| adv_cse if adv_cse[:state] == state }.compact
		cases.group_by{ |adv_cse| adv_cse[:advocate_id] }.each { |advocate_id, all_cases|
			all_cases_for_advocate = all_cases.collect {|cse| cse[:case_id] }.join(', ')
				puts "#{advocate_id}: #{all_cases_for_advocate}"
			}
	end
end
advocate = Advocate.new