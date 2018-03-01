
resources :approvable_time_entries, only: [:index] do
  get 'report', on: :collection
  patch 'bulk_approve', on: :collection
end

resources :projects do
  resources :approvable_time_entries, only: [:index] do
    get 'report', on: :collection
    patch 'bulk_approve', on: :collection
  end
end
