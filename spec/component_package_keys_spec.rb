require 'spec_helper'

describe Domkey::View::Component do

  context "package_keys" do

    context "class method in page_component" do

      it "is a factory method" do
        expect(Domkey::View::Component).to respond_to(:package_keys)
      end

      it "but base object should not implement instance method" do
        o = Domkey::View::Component.new(-> { 'package' }, -> { 'container' })
        expect(o).to_not respond_to :package_keys
      end
    end


    context "used by custom page component" do

      class ExpectedPackageKeysExample < Domkey::View::Component
        package_keys :foo, :bla
      end

      it "raises error when package should be a hash of keys" do
        expect {
          ExpectedPackageKeysExample.new -> { 'package' }, -> { 'container' }
        }.to raise_error(ArgumentError, /Package must be a kind of hash/)
      end

      it "should raise error when keys missing" do
        expect {
          ExpectedPackageKeysExample.new({foo: -> { 'package' }, blaaaa: -> { 'package' }}, -> { 'container' })
        }.to raise_error(ArgumentError, /Package must supply keys/)
      end

      it "happy valid page component. look ma. no errors" do
        o = ExpectedPackageKeysExample.new({foo: -> { 'package' }, bla: -> { 'package' }}, -> { 'container' })
        expect(o).to respond_to :package_keys
        expect(o.package_keys).to eq [:foo, :bla]
      end

      it "package has extra keys but expected are validated" do
        hash = {foo:      -> { 'package' },
                bla:      -> { 'package' },
                extrakey: -> { 'package' }}
        expect {
          ExpectedPackageKeysExample.new(hash, -> { 'container' })
        }.to_not raise_error
      end

    end
  end

end