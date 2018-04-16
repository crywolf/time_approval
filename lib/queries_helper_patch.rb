module QueriesHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      alias_method_chain :column_content, :approved_at
    end
  end

  module InstanceMethods
    def column_content_with_approved_at(column, issue)
      if column.name == :approved && issue.approved_at
        column_content_without_approved_at(column, issue)  << ' (' << format_object(issue.approved_at.to_date) << ')'
      elsif column.name == :approved_comment && !issue.approved? && User.current.allowed_to?(:approvable_time_entries, nil, global: true)
        content_tag('input', nil, name: "approved_comment[#{issue.id}]", value: issue.approved_comment, type: 'text')
      else
        column_content_without_approved_at(column, issue)
      end
    end
  end
end

# Add module to QueriesHelper
QueriesHelper.send(:include, QueriesHelperPatch)