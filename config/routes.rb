# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'approvable_time_entries', to: 'approvable_time_entries#index'
patch 'approvable_time_entries', to: 'approvable_time_entries#bulk_approve'