require "spec_helper"

RSpec.describe JsonapiException do
  let(:exception) do
    double "Exception",
           class:     "JsonErrorDemoError",
           message:   Faker::Hipster.sentence,
           backtrace: [:fake_backtrace]
  end
  let(:opts) { {} }
  subject { described_class.new(exception, opts) }

  describe "#title" do
    subject { super().title }

    context "When passed a title explicitly" do
      let(:opts) { { title: "Demo Title" } }

      it { is_expected.to eq "Demo Title" }
    end

    it "is inferred from the exception class name" do
      expect(subject).to eq "Json Error Demo"
    end
  end

  describe "#detail" do
    subject { super().detail }

    context "When passed a detail explicitly" do
      let(:opts) { { detail: "Demo Detail" } }

      it { is_expected.to eq "Demo Detail" }
    end

    it "uses the exception message" do
      expect(subject).to eq exception.message
    end
  end

  describe "#status" do
    subject { super().status }

    context "When passed a status explicitly" do
      let(:opts) { { status: 404 } }

      it { is_expected.to eq 404 }
    end

    it "defaults to 422" do
      expect(subject).to eq 422
    end
  end

  describe "#id" do
    subject { super().id }

    context "When passed an ID explicitly" do
      let(:opts) { { id: "123" } }

      it { is_expected.to eq "123" }
    end

    it "defaults to the exceptions object_id" do
      expect(subject).to eq exception.object_id
    end
  end

  describe "#code" do
    subject { super().code }
    let(:code) { "10 PRINT \"hello, world!\"\n20 GOTO 10\n" }
    let(:opts) { { code: code } }

    it { is_expected.to eq code }
  end

  describe "#links" do
    subject { super().links }
    let(:opts) { { links: :links } }
    it { is_expected.to eq :links }
  end

  describe "#meta" do
    subject { super().meta }

    context "When passed a meta explicitly" do
      let(:opts) { { meta: :meta } }

      it { is_expected.to eq :meta }
    end

    def self.with_rails_errors(enabled:)
      before do
        rails = double("Rails")
        allow(rails).to receive_message_chain("application.config.action_dispatch.show_exceptions").and_return(true)
        stub_const("Rails", rails)
      end
    end

    context "When Rails is configured to show errors" do
      with_rails_errors(enabled: true)

      describe "[:class]" do
        subject { super()[:class] }

        it { is_expected.to eq "JsonErrorDemoError" }
      end

      describe "[:message]" do
        subject { super()[:message] }

        it { is_expected.to eq exception.message }
      end

      describe "[:backtrace]" do
        subject { super()[:backtrace] }

        it { is_expected.to eq [:fake_backtrace] }
      end
    end
  end

  describe "#for_render" do
    subject { super().for_render }

    describe "[:json]" do
      subject { super()[:json] }
      it { is_expected.not_to eq nil }
    end

    describe "[:status]" do
      subject { super()[:status] }
      it { is_expected.to eq 422 }
    end

    describe "[:content_type]" do
      subject { super()[:content_type] }
      it { is_expected.to eq "application/vnd.api+json" }
    end
  end

  describe "#as_json" do
    subject { super().as_json }

    it { is_expected.to have_key :errors }

    describe "[:errors]" do
      subject { super()[:errors] }

      it { is_expected.to be_an(Enumerable) }
    end
  end

  describe "#to_h" do
    subject { super().to_h }

    describe "[:title]" do
      let(:opts) { { title: "Title" } }
      subject { super()[:title] }
      it { is_expected.to eq "Title" }
    end

    describe "[:links]" do
      let(:opts) { { links: "Links" } }
      subject { super()[:links] }
      it { is_expected.to eq "Links" }
    end

    describe "[:detail]" do
      let(:opts) { { detail: "Detail" } }
      subject { super()[:detail] }
      it { is_expected.to eq "Detail" }
    end

    describe "[:status]" do
      subject { super()[:status] }
      it { is_expected.to eq "422" }
    end

    describe "[:id]" do
      let(:opts) { { id: "12345" } }
      subject { super()[:id] }
      it { is_expected.to eq "12345" }
    end

    describe "[:code]" do
      let(:opts) { { code: "Code" } }
      subject { super()[:code] }
      it { is_expected.to eq "Code" }
    end
  end
end
