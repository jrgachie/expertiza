require 'spec_helper'
require 'rails_helper'

describe ReviewMappingHelper, type: :helper do

  describe 'get_team_colour' do
    before(:each) do
      @assignment = create(:assignment, created_at: DateTime.now.in_time_zone - 13.day)
    end

    it 'should return \'red\' if response_map does not exist in Responses' do
      response_map = create(:review_response_map)

      colour = get_team_colour(response_map)
      expect(colour).to eq('red')
    end

    it 'should not return \'red\' if response_map exists in Responses' do
      response_map = create(:review_response_map)
      create(:response, response_map: response_map)

      colour = get_team_colour(response_map)
      expect(colour).not_to eq('red')
    end

    it 'should return \'brown\' if reviewer (and its review_grade) both exist' do
      review_grade = create(:review_grade)
      reviewer = create(:participant, review_grade: review_grade)
      response_map = create(:review_response_map, reviewer: reviewer)
      create(:response, response_map: response_map)

      colour = get_team_colour(response_map)
      expect(colour).to eq('brown')
    end

    it 'should not return \'brown\' if review_grade is nil' do
      reviewer = create(:participant, review_grade: nil)
      response_map = create(:review_response_map, reviewer: reviewer)
      create(:response, response_map: response_map)

      colour = get_team_colour(response_map)
      expect(colour).not_to eq('brown')
    end

    it 'should not return \'blue\' if a review was not submitted in each round' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 3)
      reviewer = create(:participant, review_grade: nil)
      response_map = create(:review_response_map, reviewer: reviewer)
      create(:response, response_map: response_map)

      colour = get_team_colour(response_map)
      expect(colour).not_to eq('blue')
    end

    it 'should return \'green\' if the submission link does not exist' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      reviewer = create(:participant, review_grade: nil)
      response_map = create(:review_response_map, reviewer: reviewer)
      create(:response, response_map: response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2)

      colour = get_team_colour(response_map)
      expect(colour).to eq('green')
    end

    it 'should return \'green\' if the submission link is not a wiki link' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:assignment_team, assignment: @assignment)
      reviewer = create(:participant, review_grade: nil)
      reviewee = create(:assignment_team)
      response_map = create(:review_response_map, reviewer: reviewer, reviewee: reviewee)
      create(:submission_record, assignment_id: @assignment.id, team_id: reviewee.id, operation: 'Submit Hyperlink', content: 'not a wiki link')
      create(:response, response_map: response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2)

      colour = get_team_colour(response_map)
      expect(colour).to eq('green')
    end

    it 'should return \'purple\' if review was submitted within each round' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:assignment_team, assignment: @assignment)
      reviewer = create(:participant, review_grade: nil)
      reviewee = create(:assignment_team)
      response_map = create(:review_response_map, reviewer: reviewer, reviewee: reviewee)
      create(:submission_record, assignment_id: @assignment.id, team_id: reviewee.id, operation: 'Submit Hyperlink', content: 'not a wiki link')
      create(:submission_record, assignment_id: @assignment.id, team_id: reviewee.id, operation: 'Submit Hyperlink', content: 'not a wiki link', created_at: DateTime.now.in_time_zone + 4.day)
      create(:response, response_map: response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone + 3.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone + 6.day)

      colour = get_team_colour(response_map)
      expect(colour).to eq('purple')
    end

    it 'should return \'purple\' if the submitted wiki link has been updated since the due date for that round' do
      create(:deadline_right, name: 'No')
      create(:deadline_right, name: 'Late')
      create(:deadline_right, name: 'OK')
      create(:assignment_team, assignment: @assignment)
      reviewer = create(:participant, review_grade: nil)
      reviewee = create(:assignment_team)
      response_map = create(:review_response_map, reviewer: reviewer, reviewee: reviewee)
      create(:submission_record, assignment_id: @assignment.id, team_id: reviewee.id, operation: 'Submit Hyperlink', content: 'https://wiki.archlinux.org/', created_at: DateTime.now.in_time_zone - 7.day)
      create(:response, response_map: response_map)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 1, due_at: DateTime.now.in_time_zone - 5.day)
      create(:assignment_due_date, assignment: @assignment, parent_id: @assignment.id, round: 2, due_at: DateTime.now.in_time_zone + 6.day)

      colour = get_team_colour(response_map)
      expect(colour).to eq('purple')
    end
  end

  describe 'link_updated_since_last?' do

  end

end
