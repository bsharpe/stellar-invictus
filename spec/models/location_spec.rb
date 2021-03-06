require 'rails_helper'

describe Location do
  context 'new location' do
    describe 'attributes' do
      it { should respond_to :users }
      it { should respond_to :system }
      it { should respond_to :location_type }
      it { should respond_to :faction }
      it { should respond_to :jumpgate }
      it { should respond_to :name }
      it { should respond_to :asteroids }
      it { should respond_to :structures }
      it { should respond_to :spaceships }
      it { should respond_to :market_listings }
      it { should respond_to :missions }
    end

    describe 'Relations' do
      it { should belong_to :system }
      it { should have_many :users }
      it { should have_many :asteroids }
      it { should have_many :structures }
      it { should have_many :spaceships }
      it { should have_many :market_listings }
      it { should have_many :missions }
    end

    describe 'Enums' do
      it { should define_enum_for(:location_type).with_values([:station, :asteroid_field, :jumpgate, :mission, :exploration_site, :wormhole]) }
      it { should define_enum_for(:station_type).with_values([:industrial_station, :warfare_plant, :mining_station, :research_station, :trillium_casino]) }
    end

    describe 'Functions' do
      before(:each) do
        @user = FactoryBot.create(:user_with_faction)
      end

      describe 'jumpgate' do
        it 'should return associated jumpgate' do
          @location = Location.where(location_type: :jumpgate).first
          expect(@location.jumpgate).to eq(Jumpgate.first)
        end
      end

      describe 'get_items' do
        it 'should return items of current_user in this station' do
          @location = Location.where(location_type: :station).first
          Item.create(loader: "test", user: @user, location: @location, count: 3)
          expect(@location.get_items(@user.id).first.count).to eq(3)
        end

        it 'should return no items of current_user in this station if has no items' do
          @location = Location.where(location_type: :station).first
          expect(@location.get_items(@user.id)).to eq([])
        end
      end

      describe 'before_destroy' do
        it 'should move users away from self' do
          location = Location.where(location_type: :station).first
          user = FactoryBot.create(:user_with_faction, location: location)
          location.destroy
          expect(user.reload.location.id).not_to eq(location.id)
        end
      end

      describe 'get_name' do
        it 'should get name of station' do
          location = Location.where(location_type: :station).first
          expect(location.get_name).to eq(I18n.t("locations.#{location.station_type}"))
        end

        it 'should get name of jumpgate' do
          location = Location.where(location_type: :jumpgate).first
          expect(location.get_name).to eq(location.name)
        end

        it 'should get name of asteroid field' do
          location = Location.where(location_type: :asteroid_field).first
          expect(location.get_name).to eq("#{I18n.t("locations.#{location.location_type}")} #{location.name}")
        end
      end
    end
  end
end
