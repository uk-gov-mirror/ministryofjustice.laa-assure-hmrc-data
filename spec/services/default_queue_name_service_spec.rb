require "rails_helper"

RSpec.describe DefaultQueueNameService do
  describe ".call" do
    subject(:call) { described_class.call }

    context "when the service is called anywhere other than UAT" do
      before do
        allow(Rails.configuration.x).to receive(:host_env).and_return("foobar")
      end

      it "sets the submission queue name to \"default\"" do
        expect(call).to eq "default"
      end
    end

    context "when the service is called in UAT" do
      before do
        allow(Rails.configuration.x).to receive(:host_env).and_return("uat")
      end

      context "with prefixed using / in branch name" do
        before do
          allow(Rails.configuration.x.status).to receive(:app_branch).and_return("security/a_test_branch")
        end

        it "removes the prefix delimited by /" do
          expect(call).to eq "default-a-test-branch"
        end
      end

      context "with upper_case letters in branch name" do
        before do
          allow(Rails.configuration.x.status).to receive(:app_branch).and_return("a_TEST_branch")
        end

        it "removes the prefix delimited by /" do
          expect(call).to eq "default-a-test-branch"
        end
      end

      context "with special characters in branch name" do
        before do
          allow(Rails.configuration.x.status).to receive(:app_branch).and_return("a[test.branch]_(here)")
        end

        it "replaces and squeezes the characters \" _[]().\" into hyphens and removes a trailing hyphen" do
          expect(call).to eq "default-a-test-branch-here"
        end
      end

      context "with whitespace characters in branch name" do
        before do
          allow(Rails.configuration.x.status).to receive(:app_branch).and_return(" a test branch ")
        end

        it "squishes leading and trailing whitespace and replaces internal spaces with hyphens" do
          expect(call).to eq "default-a-test-branch"
        end
      end

      context "with branch names over 30 characters in length" do
        before do
          allow(Rails.configuration.x.status)
            .to receive(:app_branch)
            .and_return("a-test-branch-that-is-definitely-over-thirty-characters")
        end

        it "truncates the branch name to 30 characters, before appending it to the default prefix" do
          expect(call).to eq "default-a-test-branch-that-is-definite"
        end
      end
    end
  end
end
