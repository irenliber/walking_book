class Book < ApplicationRecord

  include PgSearch
  pg_search_scope :search_by_book_info, :against => [:title, :author_name]

  enum status: [:available, :busy]
  enum category: [:fiction, :education, :children, :other]

  belongs_to :user
  belongs_to :image
  has_many   :histories
  has_many   :users, through: :histories

  validates_presence_of :title, :description, :category, :author_name
  validate :fill_coordinates

  after_update :create_history
  after_create :create_history

  acts_as_mappable :default_units => :kms,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :lat,
                   :lng_column_name => :lng

  private

  def create_history
    if saved_change_to_user_id?
      History.create(book: self, user: user)
    end
  end

  def fill_coordinates
    if user.present? and user.lat.present? and user.lng.present?
      self.lat = user.lat
      self.lng = user.lng
    else
      errors.add(:base, 'You should add an address before create a book')
    end
  end

end
