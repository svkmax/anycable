# frozen_string_literal: true

require "spec_helper"

describe Anycable::Config do
  subject(:config) { Anycable.config }

  it "loads config vars from anycable.yml", :aggregate_failures do
    expect(config.rpc_host).to eq "localhost:50123"
    expect(config.redis_channel).to eq "__anycable__"
    expect(config.log_level).to eq :info
    expect(config.log_grpc).to eq false
  end

  context "when DEBUG is set" do
    around { |ex| with_env("ANYCABLE_DEBUG" => "1", &ex) }

    subject(:config) { described_class.new }

    it "sets log to debug and log_grpc to true" do
      expect(config.log_level).to eq :debug
      expect(config.log_grpc).to eq true
    end
  end

  describe "#to_redis_params" do
    let(:sentinel_config) do
      [
        { "host" => "redis-1-1", "port" => 26_379 },
        { "host" => "redis-1-2", "port" => 26_380 }
      ]
    end

    context "with sentinel" do
      before do
        config.redis_sentinels = sentinel_config
      end

      specify do
        expect(subject.to_redis_params).to eq(
          url: "redis://localhost:6379/2",
          sentinels: [{ "host" => "redis-1-1", "port" => 26_379 }, { "host" => "redis-1-2", "port" => 26_380 }]
        )
      end
    end

    context "without sentinel" do
      before do
        config.redis_sentinels = []
      end

      specify do
        expect(subject.to_redis_params).to eq(
          url: "redis://localhost:6379/2"
        )
      end
    end
  end
end
