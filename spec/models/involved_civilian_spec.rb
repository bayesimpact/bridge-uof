require 'rails_helper'

describe '[Involved Civilian]', type: :model do
  describe 'valid?' do
    before :each do
      @civilian = create :involved_civilian
    end

    it 'validates a model with all correct fields' do
      expect(@civilian.valid?).to be true
    end

    it 'returns true when the mental_status field contains several accepted values' do
      @civilian.mental_status = ['Signs of physical disability', 'Signs of drug impairment']
      expect(@civilian.valid?).to be true
    end

    it 'returns false when the mental_status field contains "None" option and other values' do
      @civilian.mental_status = ['Signs of physical disability', 'Signs of drug impairment', 'None']
      expect(@civilian.valid?).to be false
    end

    it 'returns false when the mental_status field contains an unkown value' do
      @civilian.mental_status = ['This is not a mental status.']
      expect(@civilian.valid?).to be false
    end

    it 'returns false when the mental_status field contains a duplicate value' do
      @civilian.mental_status = ['Signs of physical disability', 'Signs of physical disability']
      expect(@civilian.valid?).to be false
    end

    it 'returns true when the perceived_armed_weapon contains known weapons' do
      @civilian.perceived_armed = true
      @civilian.perceived_armed_weapon = ['Firearm', 'Other dangerous weapon']
      expect(@civilian.valid?).to be true
    end

    it 'returns false when the perceived_armed_weapon contains an unknown weapon' do
      @civilian.perceived_armed = true
      @civilian.perceived_armed_weapon = ['Big mouth']
      expect(@civilian.valid?).to be false
    end

    it 'returns true when the received_force_type contains known force types' do
      @civilian.received_force = true
      @civilian.received_force_type = ['Blunt / impact weapon', 'Electronic control device']
      @civilian.received_force_location = ['Head']
      expect(@civilian.valid?).to be true
    end

    it 'returns false when the received_force_type contains a duplicate' do
      @civilian.received_force = true
      @civilian.received_force_type = ['Blunt / impact weapon', 'Blunt / impact weapon']
      @civilian.received_force_location = ['Head']
      expect(@civilian.valid?).to be false
    end
  end
end
