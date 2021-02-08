describe Travis::Yaml::Matrix do
  let(:matrix) { config.to_matrix }
  let(:entries) { matrix.entries }
  let(:matrix_attributes) { entries.first.matrix_attributes }

  context 'no matrix' do
    let(:config) { Travis::Yaml.load(language: 'ruby') }
    specify { expect(matrix.size).to be == 1 }
    specify { expect(entries.first.to_ruby).to be == { 'language' => 'ruby', 'os' => ['linux'] } }
    specify { expect(config.to_ruby).to be == { 'language' => 'ruby', 'os' => ['linux'] } }
    specify { expect(entries.first).to be_a(Travis::Yaml::Matrix::Entry) }
    specify { expect(matrix_attributes).to be_empty }
    specify { expect(matrix.axes).to be_empty }
  end

  context 'simple matrix' do
    let(:config) { Travis::Yaml.load(ruby: %w[ruby jruby]) }
    specify { expect(matrix.size).to be == 2 }
    specify do
      expect(entries.first.to_ruby).to be == { 'language' => 'ruby', 'os' => ['linux'], 'ruby' => 'ruby' }
    end
    specify { expect(config.to_ruby).to be == { 'language' => 'ruby', 'os' => ['linux'], 'ruby' => %w[ruby jruby] } }
    specify { expect(entries.first).to be_a(Travis::Yaml::Matrix::Entry) }
    specify { expect(matrix_attributes).to be == { ruby: 'ruby' } }
    specify { expect(matrix.axes).to be == [:ruby] }
  end

  context 'two dimensional matrix' do
    let(:config) { Travis::Yaml.load(ruby: %w[ruby jruby], os: %w[linux osx]) }
    specify do
      expect(matrix.size).to be == 4
    end
    specify do
      expect(entries.first.to_ruby).to be == { 'language' => 'ruby', 'os' => 'linux',
                                               'ruby' => 'ruby' }
    end
    specify do
      expect(config.to_ruby).to be == { 'language' => 'ruby', 'os' => %w[linux osx], 'ruby' => %w[ruby jruby] }
    end
    specify do
      expect(entries.first).to be_a(Travis::Yaml::Matrix::Entry)
    end
    specify do
      expect(matrix_attributes).to be == { ruby: 'ruby', os: 'linux' }
    end
    specify do
      expect(matrix.axes).to be == %i[ruby os]
    end
  end

  context 'matrix env, no global env' do
    let(:config) { Travis::Yaml.load(env: %w[a b]) }
    specify do
      expect(matrix.size).to be == 2
    end
    specify do
      expect(entries.first.to_ruby).to be == { 'env' => { 'global' => ['a'] }, 'language' => 'ruby',
                                               'os' => ['linux'] }
    end
    specify do
      expect(entries.last.to_ruby).to be == { 'env' => { 'global' => ['b'] }, 'language' => 'ruby',
                                              'os' => ['linux'] }
    end
    specify do
      expect(config.to_ruby).to be == { 'env' => { 'matrix' => %w[a b] }, 'language' => 'ruby', 'os' => ['linux'] }
    end
    specify do
      expect(entries.first).to be_a(Travis::Yaml::Matrix::Entry)
    end
    specify do
      expect(matrix_attributes).to be == { env: 'a' }
    end
    specify do
      expect(matrix.axes).to be == [:env]
    end
  end

  context 'matrix env, global env' do
    let(:config) { Travis::Yaml.load(env: { matrix: %w[a b], global: ['x'] }) }
    specify do
      expect(matrix.size).to be == 2
    end
    specify do
      expect(entries.first.to_ruby).to be == { 'env' => { 'global' => %w[x a] }, 'language' => 'ruby',
                                               'os' => ['linux'] }
    end
    specify do
      expect(entries.last.to_ruby).to be == { 'env' => { 'global' => %w[x b] }, 'language' => 'ruby',
                                              'os' => ['linux'] }
    end
    specify do
      expect(config.to_ruby).to be == { 'env' => { 'matrix' => %w[a b], 'global' => ['x'] }, 'language' => 'ruby',
                                        'os' => ['linux'] }
    end
    specify do
      expect(entries.first).to be_a(Travis::Yaml::Matrix::Entry)
    end
    specify do
      expect(matrix_attributes).to be == { env: 'a' }
    end
    specify do
      expect(matrix.axes).to be == [:env]
    end
  end
end
