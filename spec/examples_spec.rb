def run_example(file_name)
  expect(system("truffleruby src/main.rb examples/#{file_name}.rad >> /dev/null")).to be_truthy
end

RSpec.describe "examples" do
  it "math.rad" do
    run_example("math")
  end
end
