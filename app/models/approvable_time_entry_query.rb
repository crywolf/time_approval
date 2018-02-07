class ApprovableTimeEntryQuery < TimeEntryQuery

  self.available_columns << QueryColumn.new(:approved, sortable: "#{TimeEntry.table_name}.approved")

  def default_columns_names
    @default_columns_names ||= super << :approved
  end

  def initialize_available_filters
    super
    add_available_filter "approved", type: :list, values: [[l('general_text_No'), "false"]]
  end

end