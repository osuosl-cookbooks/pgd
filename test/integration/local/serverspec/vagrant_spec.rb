require 'serverspec'

describe user('vagrant') do
  it { should exist }
end

describe group('vagrant') do
  it { should exist }
end
