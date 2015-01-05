secrets = Chef::EncryptedDataBagItem.load('pgd', 'pgd_secrets')

if node['pgd']['database']['engine'].nil?
    Chef::Log.fatal "node['pgd']['database']['engine'] is not set, which is considered an error. Please set it"
    fail "node['pgd']['database']['engine'] is not set"
end
