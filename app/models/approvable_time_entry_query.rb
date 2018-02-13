class ApprovableTimeEntryQuery < TimeEntryQuery

  self.available_columns << QueryColumn.new(:approved, sortable: "#{self.queried_class.table_name}.approved")
  self.available_columns << QueryColumn.new(:approved_by)

  def default_columns_names
    @default_columns_names ||= super.push(:approved, :approved_by)
  end

  def initialize_available_filters
    super
    # add filter field "Approved by" to selectbox
    users = User.all.to_a.reject! {|u| !u.allowed_to?(:approvable_time_entries, nil, global: true)}
    users_values = []
    users_values << ["<< #{l(:label_me)} >>", "me"] if User.current.logged?
    users_values += users.collect{|s| [s.name, s.id.to_s] }
    add_available_filter("approved_by_user_id",
      :type => :list_optional, :values => users_values
    ) unless users_values.empty?
  end

  def build_from_params(params)
    super
    # replace placeholder "me" with current user ID
    value = values_for('approved_by_user_id')
    if value
      if value.delete("me")
        value.push(User.current.id.to_s)
      end
    end
    self
  end

end