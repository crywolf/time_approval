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
        column_content_without_approved_at(column, issue)  << ' (' << I18n::l(issue.approved_at, format: "%e.%_m.%Y") << ')'
      else
        column_content_without_approved_at(column, issue)
      end
    end
  end
end

# Add module to QueriesHelper
QueriesHelper.send(:include, QueriesHelperPatch)