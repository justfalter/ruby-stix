class Java::OrgMitreCyboxCore::ObservablesType
  include StixRuby::DocumentWriter

  def process_args(args)
    args[:cybox_update_version] = "1"
    args
  end
end