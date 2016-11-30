require 'rails_helper'

RSpec.describe AdditionalSubmissionInformation, type: :model do
  describe 'validations' do
    let(:asi) { build(:asi) }

    describe 'k_9_officer_severirly_injured_count' do
      it 'raises errors if < 0' do
        asi.k_9_officer_severirly_injured_count = -1
        asi.validate
        expect(asi.errors[:k_9_officer_severirly_injured_count]).to include 'must be greater than 0'
      end

      it 'raises errors if blank' do
        asi.k_9_officer_severirly_injured_count = ''
        asi.validate
        expect(asi.errors[:k_9_officer_severirly_injured_count]).to include "can't be blank"
      end
    end

    describe 'non_sworn_uniformed_injured_or_killed_count' do
      it 'raises errors if < 0' do
        asi.non_sworn_uniformed_injured_or_killed_count = -1
        asi.validate
        expect(asi.errors[:non_sworn_uniformed_injured_or_killed_count]).to include 'must be greater than 0'
      end

      it 'raises errors if blank' do
        asi.non_sworn_uniformed_injured_or_killed_count = ''
        asi.validate
        expect(asi.errors[:non_sworn_uniformed_injured_or_killed_count]).to include "can't be blank"
      end
    end

    describe 'civilians_injured_or_killed_by_non_sworn_uniformed_count' do
      it 'raises errors if < 0' do
        asi.civilians_injured_or_killed_by_non_sworn_uniformed_count = -1
        asi.validate
        expect(asi.errors[:civilians_injured_or_killed_by_non_sworn_uniformed_count]).to include 'must be greater than 0'
      end

      it 'raises errors if blank' do
        asi.civilians_injured_or_killed_by_non_sworn_uniformed_count = nil
        asi.validate
        expect(asi.errors[:civilians_injured_or_killed_by_non_sworn_uniformed_count]).to include "can't be blank"
      end
    end

    it 'raises errors when duplicates' do
      asi.save
      duplicate = build(:asi)
      duplicate.validate
      expect(duplicate.errors[:ori]).to include 'with voluntary information has already been submitted.'
    end
  end
end
