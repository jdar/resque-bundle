# -*- encoding: utf-8 -*-

module RSpecMacros
  def self.included(spec)
    spec.let(:config) do
      {
        folder:     '/tmp/path/to/your/cache/folder',
      }
    end
  end
end

