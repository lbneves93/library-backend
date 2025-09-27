require 'rails_helper'

RSpec.describe User, type: :model do
  context "when creating valid member" do
    let(:user) { build(:user, role: User.roles["member"]) }

    it { expect(user).to be_valid }
  end

  context "when creating valid librarian" do
    let(:user) { build(:user, role: User.roles["librarian"]) }

    it { expect(user).to be_valid }
  end

  context "when creating invalid user" do
    let(:user) { build(:user, role: User.roles["invalid"]) }

    it { expect(user).to be_invalid }
  end
end
