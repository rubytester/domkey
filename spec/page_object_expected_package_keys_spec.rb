require 'spec_helper'

describe Domkey::View::PageObject do

  context "expected_package_keys" do

    context "class method in pageobject" do

      it "is a factory method" do
        expect(Domkey::View::PageObject).to respond_to(:expected_package_keys)
      end

      it "but base object should not implement instance method" do
        o = Domkey::View::PageObject.new(-> { 'package' }, -> { 'container' })
        expect(o).to_not respond_to :expected_package_keys
      end
    end


    context "used by custom page object" do

      class ExpectedPackageKeysExample < Domkey::View::PageObject
        expected_package_keys :foo, :bla
      end

      it "raises error when package should be a hash of keys" do
        expect {
          ExpectedPackageKeysExample.new -> { 'package' }, -> { 'container' }
        }.to raise_error(ArgumentError, /Expected package to be a kind of hash/)
      end

      it "should raise error when keys missing" do
        expect {
          ExpectedPackageKeysExample.new({foo: -> { 'package' }, blaaaa: -> { 'package' }}, -> { 'container' })
        }.to raise_error(ArgumentError, /package to be constructed with keys/)
      end

      it "happy valid page object. look ma. no errors" do
        o = ExpectedPackageKeysExample.new({foo: -> { 'package' }, bla: -> { 'package' }}, -> { 'container' })
        expect(o).to respond_to :expected_package_keys
        expect(o.expected_package_keys).to eq [:foo, :bla]
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