require 'acceptance_helper'

feature 'Delete question', %(
  To hide question from community
  As an user
  I can to able to remove question
) do

  given!(:user) { create(:user_with_questions, question_count: 1) }

  scenario 'Not-authorized user does not remove question' do
    visit questions_path
    expect(page).not_to have_content 'Remove question'
  end

  scenario 'Author can remove his question' do
    sign_in(user)

    visit questions_path
    click_on 'Remove question', match: :first

    expect(current_path).to eq questions_path
    expect(page).to_not have_content 'Simple title'
    expect(page).to_not have_content 'Placeholder for body'
    expect(page).to have_content 'Question was successfully destroyed'
  end

  scenario 'Not-author can not remove not his question' do
    new_user = create(:user)
    sign_in(new_user)

    visit questions_path

    expect(page).to have_content('Simple title', count: 1)
    expect(page).to_not have_link 'Remove question'
  end
end
