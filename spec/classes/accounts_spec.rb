require 'spec_helper'

describe 'accounts' do

  context 'with no parameters' do
    it { should compile.with_all_deps }
  end

  context 'whith groups only' do
    let(:params) do
      {
        :groups => {
          'foo' => {},
          'bar' => {},
	  'baz' => { 'ensure' => 'absent' },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(3) }
    it { should contain_group('foo').with({ :ensure => nil }) }
    it { should contain_group('bar').with({ :ensure => nil }) }
    it { should contain_group('baz').with({ :ensure => :absent }) }

    it { should have_ssh_authorized_key_resource_count(0) }

    it { should have_user_resource_count(0) }
  end

  context 'with public_keys only' do
    let(:params) do
      {
        :public_keys => {
          'foo' => {
            'type' => 'ssh-rsa',
            'key'  => 'FOO-S-RSA-PUBLIC-KEY',
          },
          'bar' => {
            'type'   => 'ssh-rsa',
            'key'    => 'BAR-S-RSA-PUBLIC-KEY',
          },
          'baz' => {
            'ensure' => 'absent',
            'type'   => 'ssh-rsa',
            'key'    => 'BAR-S-RSA-PUBLIC-KEY',
          },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(0) }

    it { should have_user_resource_count(0) }
  end

  context 'with users only' do
    let(:params) do
      {
        :users => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
          'bar' => {
            'comment' => 'Bar User',
            'uid'     => 1001,
          },
          'baz' => {
            'ensure'  => 'absent',
            'comment' => 'Baz User',
            'uid'     => 1002,
          },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(0) }

    it { should have_user_resource_count(1) }
    it { should contain_user('baz').with({ :ensure => :absent })}
  end

  context 'when adding an account with no public key' do
    let(:params) do
      {
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
        :accounts    => {
          'foo' => { },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(0) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo') }
  end

  context 'when adding an account in a group not declared' do
    let(:params) do
      {
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
        :accounts    => {
          'foo' => {
            'groups' => [ 'foo', ],
          },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(0) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo').with({ :groups => [ 'foo', ] }) }
  end

  context 'when adding an account in a group declared' do
    let(:params) do
      {
        :groups      => {
          'foo' => { },
        },
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
        :accounts    => {
          'foo' => {
            'groups' => [ 'foo', ],
          },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(1) }
    it { should contain_group('foo').with({ :ensure => nil }) }

    it { should have_ssh_authorized_key_resource_count(0) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo').with({ :groups => [ 'foo', ] }) }
  end

  context 'when adding an account in multiple groups' do
    let(:params) do
      {
        :groups      => {
          'foo' => { },
        },
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
        :accounts    => {
          'foo' => {
            'groups' => [ 'foo', 'bar', ],
          },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(1) }
    it { should contain_group('foo').with({ :ensure => nil }) }

    it { should have_ssh_authorized_key_resource_count(0) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo').with({ :groups => [ 'foo', 'bar', ] }) }
  end

  context 'when adding an account with only its public_key' do
    let(:params) do
      {
        :public_keys => {
          'foo' => {
            'type'   => 'ssh-rsa',
            'key'    => 'FOO-S-RSA-PUBLIC-KEY',
          },
        },
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
        :accounts    => {
          'foo' => { },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(1) }
    it { should contain_ssh_authorized_key('foo-on-foo').with({ :user => 'foo' }) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo') }
  end

  context 'when adding an account with multiple public_keys' do
    let(:params) do
      {
        :public_keys => {
          'foo' => {
            'type'   => 'ssh-rsa',
            'key'    => 'FOO-S-RSA-PUBLIC-KEY',
          },
          'bar' => {
            'type'   => 'ssh-rsa',
            'key'    => 'BAR-S-RSA-PUBLIC-KEY',
          },
        },
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
        :accounts    => {
          'foo' => {
            'authorized_keys' => [ 'bar' ],
	  },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(2) }
    it { should contain_ssh_authorized_key('foo-on-foo').with({ :user => 'foo' }) }
    it { should contain_ssh_authorized_key('bar-on-foo').with({ :user => 'foo' }) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo') }
  end

  context 'when removing an account' do
    let(:params) do
      {
        :public_keys => {
          'foo' => {
            'type'   => 'ssh-rsa',
            'key'    => 'FOO-S-RSA-PUBLIC-KEY',
          },
          'bar' => {
            'type'   => 'ssh-rsa',
            'key'    => 'BAR-S-RSA-PUBLIC-KEY',
          },
        },
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
        :accounts    => {
          'foo' => {
            'ensure' => 'absent',
          },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(0) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo').with({ :ensure => :absent }) }
  end

  context 'when removing an user' do
    let(:params) do
      {
        :public_keys => {
          'foo' => {
            'type'   => 'ssh-rsa',
            'key'    => 'FOO-S-RSA-PUBLIC-KEY',
          },
          'bar' => {
            'type'   => 'ssh-rsa',
            'key'    => 'BAR-S-RSA-PUBLIC-KEY',
          },
        },
        :users       => {
          'foo' => {
            'ensure' => 'absent',
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(0) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo').with({ :ensure => :absent }) }
  end

  context 'when removing a public key' do
    let(:params) do
      {
        :public_keys => {
          'foo' => {
            'type'   => 'ssh-rsa',
            'key'    => 'FOO-S-RSA-PUBLIC-KEY',
          },
          'bar' => {
            'ensure' => 'absent',
            'type'   => 'ssh-rsa',
            'key'    => 'BAR-S-RSA-PUBLIC-KEY',
          },
        },
        :users       => {
          'foo' => {
            'comment' => 'Foo User',
            'uid'     => 1000,
          },
        },
        :accounts    => {
          'foo' => { },
        },
      }
    end

    it { should compile.with_all_deps }

    it { should have_group_resource_count(0) }

    it { should have_ssh_authorized_key_resource_count(2) }
    it { should contain_ssh_authorized_key('foo-on-foo').with({ :ensure => nil }) }
    it { should contain_ssh_authorized_key('bar-on-foo').with({ :ensure => :absent }) }

    it { should have_user_resource_count(1) }
    it { should contain_user('foo') }
  end

end
