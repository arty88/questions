require 'acceptance_helper'

feature 'User create answer', %(
  To help solve the problev
  As an user
  I want to be able to answer the question
) do

  given(:user) { create(:user) }
  given(:question) { create(:question_with_answers) }

  feature "Multiple sessions", :js do
    scenario "answer appears on another user's page" do
      Capybara.using_session("user") do
        sign_in(user)
        visit question_path(question)
      end

      Capybara.using_session("guest") do
        visit question_path(question)
      end

      Capybara.using_session("user") do
        fill_in 'Body', with: 'Placeholder for answer'
        click_on 'Create Answer'

        expect(current_path).to eq question_path(question)
        expect(page).to have_content 'Answer was successfully created.'
        within '#answers' do
          expect(page).to have_content 'Placeholder for answer'
        end
      end

      Capybara.using_session("guest") do
        within '#answers' do
          expect(page).to have_content 'Placeholder for answer'
        end
      end
    end
  end

  feature 'Authenticate user' do
    before do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'can answer the question with valid attributes', js: true do
      fill_in 'Body', with: 'Placeholder for answer'
      click_on 'Create Answer'

      expect(current_path).to eq question_path(question)
      expect(page).to have_content 'Answer was successfully created.'
      within '#answers' do
        expect(page).to have_content 'Placeholder for answer'
      end
    end

    scenario 'can not answer there question with invalid attributes', js: true do
      fill_in 'Body', with: ''
      click_on 'Create Answer'

      expect(current_path).to eq question_path(question)
      expect(page)
        .to have_content('Answer could not be created')

      within '#errors_block' do
        expect(page).to have_content('Body can\'t be blank')
        expect(page).to have_content('Body is too short (minimum is 10 characters)')
      end

      within '#answers' do
        expect(page).to have_content('Answer placeholder', count: 2)
      end
    end
  end

  scenario 'Not-authenticate user does not create answer' do
    visit question_path(question)

    expect(page).to have_content 'To answer the question log in'
  end
end
