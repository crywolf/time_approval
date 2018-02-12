class ApprovableTimeEntry < TimeEntry

  belongs_to :approved_by, class_name: 'User', foreign_key: 'approved_by_user_id'

end