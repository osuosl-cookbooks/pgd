require 'serverspec'

set :background, :exec

%w(python27 libffi-devel).each do |p|
  describe package(p) do
    it { should be_installed }
  end
end

describe service('httpd') do
  it { should be_enabled }
  it { should be_running }
end

%w(/opt/pgd/settings.py /opt/pgd/selected_proteins.txt).each do |p|
  describe file(p) do
    it { should be_file }
  end
end

%w(/opt/pgd /opt/vrt).each do |p|
  describe file(p) do
    it { should be_directory }
  end
end
