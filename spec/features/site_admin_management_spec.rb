describe 'Site admin management', js: true do
  let(:user) { FactoryGirl.create(:site_admin) }
  let!(:existing_user) { FactoryGirl.create(:exhibit_visitor) }
  let!(:exhibit_admin) { FactoryGirl.create(:exhibit_admin) }
  let!(:exhibit_curator) { FactoryGirl.create(:exhibit_curator) }

  before do
    login_as(user)
    visit spotlight.admin_users_path
  end

  it 'displays the current admin users' do
    expect(page).to have_css('td', text: user.email)
  end

  describe 'copy email addresses' do
    it 'displays only email addresses of users w/ roles' do
      expect(page).to have_css('div#all_users', text: user.email)
      expect(page).to have_css('div#all_users', text: exhibit_admin.email)
      expect(page).to have_css('div#all_users', text: exhibit_curator.email)
      expect(page).not_to have_css('div#all_users', text: existing_user.email)
      expect(page).to have_css('button.copy-email-addresses')
    end
  end

  it 'allows for existing users to be added as site adminstrators' do
    expect(page).not_to have_css('td', text: existing_user.email)
    click_link 'Add new administrator'

    fill_in 'user_email', with: existing_user.email
    click_button 'Add role'

    expect(page).to have_content('Added user as an exhibits adminstrator')
    expect(page).to have_css('td', text: existing_user.email)
  end

  it 'allows non-existing users to be invited' do
    click_link 'Add new administrator'

    fill_in 'user_email', with: 'not-an-existing-user@example.com'

    click_button 'Add role'

    expect(page).to have_content('not-an-existing-user@example.com pending')
  end

  it 'allows the admin to remove the admin role from the user' do
    click_link 'Add new administrator'

    fill_in 'user_email', with: 'not-an-admin@example.com'

    click_button 'Add role'

    expect(page).to have_css(:td, text: 'not-an-admin@example.com')

    expect(page).to have_css(:a, text: 'Remove from role', count: 2)
    within(all('table tbody tr').last) do
      click_link 'Remove from role'
    end

    expect(page).to have_content 'User removed from site adminstrator role'
    expect(page).to have_css(:a, text: 'Remove from role', count: 1)

    expect(page).not_to have_css(:td, text: 'not-an-admin@example.com')
  end

  it 'does not provide a button for users to remove their own adminstrator privs' do
    click_link 'Add new administrator'

    expect(page).to have_css('td', text: user.email)
    # There are two users, the original site admin and our admin user so only one button
    expect(page).to have_css(:a, text: 'Remove from role', count: 1)
  end
end
