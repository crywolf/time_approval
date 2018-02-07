class ApprovableTimeEntryQuery < TimeEntryQuery

  self.available_columns << QueryColumn.new(:approved, sortable: "#{TimeEntry.table_name}.approved")

  def default_columns_names
    @default_columns_names ||= super << :approved
  end

end