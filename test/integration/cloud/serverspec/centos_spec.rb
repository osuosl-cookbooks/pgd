require 'serverspec'

describe user('centos') do
  it { should exist }
end

describe group('centos') do
  it { should exist }
end
