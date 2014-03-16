require './parser.rb'

describe Parser do
	filename = "test"
	p = Parser.new(filename)

	#it "should be a valid program" do		
		#expect(p.program).to eq(true)
	#end

	it "should have a valid header" do
		expect(p.program_header).to eq(true)
	end

	it "should have a valid body" do
		expect(p.program_body).to eq(true)
	end
end