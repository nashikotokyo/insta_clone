require 'rails_helper'

RSpec.describe 'ポスト', type: :system do

  describe 'ポスト一覧' do
    let!(:user) { create(:user) }
    let!(:post_1_by_others) { create(:post) }
    let!(:post_2_by_others) { create(:post) }
    let!(:post_by_user) { create(:post, user: user) }

    context 'ログインしている場合' do
      before do
        login_as user
        user.follow(post_1_by_others.user)
      end
      it 'フォロワーと自分の投稿だけが表示されること' do
        visit posts_path
        expect(page).to have_content post_1_by_others.body
        expect(page).to have_content post_by_user.body
        expect(page).not_to have_content post_2_by_others.body
      end
    end

    context 'ログインしていない場合' do
      it '全てのポストが表示されること' do
        visit posts_path
        expect(page).to have_content post_1_by_others.body
        expect(page).to have_content post_2_by_others.body
        expect(page).to have_content post_by_user.body
      end
    end
  end

  describe 'ポスト投稿' do
    it '画像を投稿できること' do
      login
      visit new_post_path
      within '#posts_form' do
        attach_file '画像', Rails.root.join('spec', 'fixtures', 'fixture.png')
        fill_in '本文', with: 'This is an example post'
        click_button '登録する'
      end

      expect(page).to have_content '投稿しました'
      expect(page).to have_content 'This is an example post'
    end
  end

  describe 'ポスト更新' do
    let!(:user) { create(:user) }
    let!(:post_1_by_others) { create(:post) }
    let!(:post_by_user) { create(:post, user: user) }
    before do
      login_as user
    end
    it '自分の投稿に編集ボタンが表示されること' do
      visit posts_path
      within "#post-#{post_by_user.id}" do
        expect(page).to have_css '.delete-button'
        expect(page).to have_css '.edit-button'
      end
    end

    it '他人の投稿には編集ボタンが表示されないこと' do
      user.follow(post_1_by_others.user)
      visit posts_path
      within "#post-#{post_1_by_others.id}" do
        expect(page).not_to have_css '.edit-button'
      end
    end

    it '投稿が更新できること' do
      visit edit_post_path(post_by_user)
      within '#posts_form' do
        attach_file '画像', Rails.root.join('spec', 'fixtures', 'fixture.png')
        fill_in '本文', with: 'This is an example updated post'
        click_button '更新する'
      end
      expect(page).to have_content '投稿を更新しました'
      expect(page).to have_content 'This is an example updated post'
    end
  end

  describe 'ポスト削除' do
    let!(:user) { create(:user) }
    let!(:post_1_by_others) { create(:post) }
    let!(:post_by_user) { create(:post, user: user) }
    before do
      login_as user
    end
    it '自分の投稿に削除ボタンが表示されること' do
      visit posts_path
      within "#post-#{post_by_user.id}" do
        expect(page).to have_css '.delete-button'
      end
    end

    it '他人の投稿には削除ボタンが表示されないこと' do
      user.follow(post_1_by_others.user)
      visit posts_path
      within "#post-#{post_1_by_others.id}" do
        expect(page).not_to have_css '.delete-button'
      end
    end

    it '投稿が削除できること' do
      visit posts_path
      within "#post-#{post_by_user.id}" do
        page.accept_confirm { find('.delete-button').click }
      end
      expect(page).to have_content '投稿を削除しました'
      expect(page).not_to have_content post_by_user.body
    end
  end

  describe 'ポスト詳細' do
    let(:user) { create(:user) }
    let(:post_by_user) { create(:post, user: user) }

    before do
      login_as user
    end

    it '投稿の詳細画面が閲覧できること' do
      visit post_path(post_by_user)
      expect(current_path).to eq post_path(post_by_user)
    end
  end

  describe 'いいね' do
    let!(:user) { create(:user) }
    let!(:post) { create(:post) }
    before do
      login_as user
      user.follow(post.user)
    end
    it 'いいねができること' do
      visit posts_path
      expect {
        within "#post-#{post.id}" do
          find('.like-button').click
          expect(page).to have_css '.unlike-button'
        end
      }.to change{user.like_posts.count}.by(1)
    end

    it 'いいねを取り消せること' do
      user.like(post)
      visit posts_path
      expect {
        within "#post-#{post.id}" do
          find('.unlike-button').click
          expect(page).to have_css '.like-button'
        end
      }.to change {user.like_posts.count}.by(-1)
    end
  end
end