class AddColumnsToUsers < ActiveRecord::Migration[5.0]
  def change
    #add_column :DB명, :컬럼명, :타입
    add_column :users, :provider, :string, null: false, default: 0    #provide는 어디로부터 정보를 받았는지를 나타냄.(구글인지 페이스북인지..)
    add_column :users, :name,     :string
    add_column :users, :uid,      :string    # uid는 토큰이라고 봐도 무방함
    
  end
end
