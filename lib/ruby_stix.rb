java_import 'javax.xml.bind.annotation.adapters.XmlJavaTypeAdapter'
require "ruby_stix/version"
require "cybox_bindings.jar"
require "stix_bindings.jar"
require "securerandom"

module StixRuby

  module Aliases
    STIXPackage         =org.mitre.stix.core.STIXType
    Campaign            =org.mitre.stix.campaign.CampaignType
    CourseOfAction      =org.mitre.stix.coa.CourseOfActionType
    ExploitTarget       =org.mitre.stix.et.ExploitTargetType
    Incident            =org.mitre.stix.incident.IncidentType
    Indicator           =org.mitre.stix.indicator.IndicatorType
    ThreatActor         =org.mitre.stix.ta.ThreatActorType
    TTP                 =org.mitre.stix.ttp.TTPType

    Observables         =org.mitre.cybox.core.ObservablesType
    Observable          =org.mitre.cybox.core.ObservableType

    module Stix
      Core              =org.mitre.stix.core
      Common            =org.mitre.stix.common
      Vocabs            =org.mitre.stix.vocabularies
    end

    module Cybox
      Core              =org.mitre.cybox.core
      Common            =org.mitre.cybox.common
      Vocabs            =org.mitre.cybox.vocabularies
    end
  end

  @id_namespace = nil
  def self.set_id_namespace(namespace, prefix)
    @id_namespace = {:uri => namespace, :prefix => prefix}
  end

  def self.id_namespace_uri
    if @id_namespace
      @id_namespace[:uri]
    else
      nil
    end
  end

  def self.id_namespace_prefix
    if @id_namespace
      @id_namespace[:prefix]
    else
      nil
    end
  end

  def self.generate_id(obj_type)
    if @id_namespace
      javax.xml.namespace.QName.new(@id_namespace[:uri], "#{obj_type}-#{SecureRandom.uuid}", @id_namespace[:prefix])
    else
      javax.xml.namespace.QName.new("#{obj_type}-#{SecureRandom.uuid}")
    end
  end

  def self.qname(localpart, uri = nil, prefix = nil)
    if prefix
      javax.xml.namespace.QName.new(uri, localpart, prefix)
    elsif uri
      javax.xml.namespace.QName.new(uri, localpart)
    elsif @id_namespace
      javax.xml.namespace.QName.new(@id_namespace[:uri], localpart, @id_namespace[:prefix])
    else
      javax.xml.namespace.QName.new(localpart)
    end
  end

  IRREGULARS = {
    Regexp.new("tt_ps") => "ttps"
  }

  NAMESPACE_MAPPINGS = {
    "http://cybox.mitre.org/common-2"=>"cyboxCommon",
    "http://cybox.mitre.org/cybox-2"=>"cybox",
    "http://cybox.mitre.org/default_vocabularies-2"=>"cyboxVocabs",
    "http://cybox.mitre.org/objects#AccountObject-2"=>"AccountObj",
    "http://cybox.mitre.org/objects#AddressObject-2"=>"AddressObj",
    "http://cybox.mitre.org/objects#APIObject-2"=>"APIObj",
    "http://cybox.mitre.org/objects#ArtifactObject-2"=>"ArtifactObj",
    "http://cybox.mitre.org/objects#CodeObject-2"=>"CodeObj",
    "http://cybox.mitre.org/objects#CustomObject-1"=>"CustomObj",
    "http://cybox.mitre.org/objects#DeviceObject-2"=>"DeviceObj",
    "http://cybox.mitre.org/objects#DiskObject-2"=>"DiskObj",
    "http://cybox.mitre.org/objects#DiskPartitionObject-2"=>"DiskPartitionObj",
    "http://cybox.mitre.org/objects#DNSCacheObject-2"=>"DNSCacheObj",
    "http://cybox.mitre.org/objects#DNSRecordObject-2"=>"DNSRecordObj",
    "http://cybox.mitre.org/objects#URIObject-2"=>"URIObj",
    "http://cybox.mitre.org/objects#DNSQueryObject-2"=>"DNSQueryObj",
    "http://cybox.mitre.org/objects#EmailMessageObject-2"=>"EmailMessageObj",
    "http://cybox.mitre.org/objects#FileObject-2"=>"FileObj",
    "http://cybox.mitre.org/objects#GUIDialogboxObject-2"=>"GUIDialogBoxObj",
    "http://cybox.mitre.org/objects#GUIObject-2"=>"GUIObj",
    "http://cybox.mitre.org/objects#GUIWindowObject-2"=>"GUIWindowObj",
    "http://cybox.mitre.org/objects#HTTPSessionObject-2"=>"HTTPSessionObj",
    "http://cybox.mitre.org/objects#PortObject-2"=>"PortObj",
    "http://cybox.mitre.org/objects#LibraryObject-2"=>"LibraryObj",
    "http://cybox.mitre.org/objects#LinkObject-1"=>"LinkObj",
    "http://cybox.mitre.org/objects#LinuxPackageObject-2"=>"LinuxPackageObj",
    "http://cybox.mitre.org/objects#MemoryObject-2"=>"MemoryObj",
    "http://cybox.mitre.org/objects#MutexObject-2"=>"MutexObj",
    "http://cybox.mitre.org/objects#NetworkConnectionObject-2"=>"NetworkConnectionObj",
    "http://cybox.mitre.org/objects#SocketAddressObject-1"=>"SocketAddressObj",
    "http://cybox.mitre.org/objects#NetworkFlowObject-2"=>"NetFlowObj",
    "http://cybox.mitre.org/objects#PacketObject-2"=>"PacketObj",
    "http://cybox.mitre.org/objects#NetworkRouteEntryObject-2"=>"NetworkRouteEntryObj",
    "http://cybox.mitre.org/objects#NetworkRouteObject-2"=>"NetworkRouteObj",
    "http://cybox.mitre.org/objects#NetworkSocketObject-2"=>"NetworkSocketObj",
    "http://cybox.mitre.org/objects#NetworkSubnetObject-2"=>"NetworkSubnetObj",
    "http://cybox.mitre.org/objects#PDFFileObject-1"=>"PDFFileObj",
    "http://cybox.mitre.org/objects#PipeObject-2"=>"PipeObj",
    "http://cybox.mitre.org/objects#ProcessObject-2"=>"ProcessObj",
    "http://cybox.mitre.org/objects#ProductObject-2"=>"ProductObj",
    "http://cybox.mitre.org/objects#SemaphoreObject-2"=>"SemaphoreObj",
    "http://cybox.mitre.org/objects#SystemObject-2"=>"SystemObj",
    "http://cybox.mitre.org/objects#UnixFileObject-2"=>"UnixFileObj",
    "http://cybox.mitre.org/objects#UnixNetworkRouteEntryObject-2"=>"UnixNetworkRouteEntryObj",
    "http://cybox.mitre.org/objects#UnixPipeObject-2"=>"UnixPipeObj",
    "http://cybox.mitre.org/objects#UnixProcessObject-2"=>"UnixProcessObj",
    "http://cybox.mitre.org/objects#UnixUserAccountObject-2"=>"UnixUserAccountObj",
    "http://cybox.mitre.org/objects#UserAccountObject-2"=>"UserAccountObj",
    "http://cybox.mitre.org/objects#UnixVolumeObject-2"=>"UnixVolumeObj",
    "http://cybox.mitre.org/objects#VolumeObject-2"=>"VolumeObj",
    "http://cybox.mitre.org/objects#UserSessionObject-2"=>"UserSessionObj",
    "http://cybox.mitre.org/objects#WhoisObject-2"=>"WhoisObj",
    "http://cybox.mitre.org/objects#WinComputerAccountObject-2"=>"WinComputerAccountObj",
    "http://cybox.mitre.org/objects#WinCriticalSectionObject-2"=>"WinCriticalSectionObj",
    "http://cybox.mitre.org/objects#WinDriverObject-2"=>"WinDriverObj",
    "http://cybox.mitre.org/objects#WinEventLogObject-2"=>"WinEventLogObj",
    "http://cybox.mitre.org/objects#WinEventObject-2"=>"WinEventObj",
    "http://cybox.mitre.org/objects#WinHandleObject-2"=>"WinHandleObj",
    "http://cybox.mitre.org/objects#WinExecutableFileObject-2"=>"WinExecutableFileObj",
    "http://cybox.mitre.org/objects#WinFileObject-2"=>"WinFileObj",
    "http://cybox.mitre.org/objects#WinKernelHookObject-2"=>"WinKernelHookObj",
    "http://cybox.mitre.org/objects#WinKernelObject-2"=>"WinKernelObj",
    "http://cybox.mitre.org/objects#WinMailslotObject-2"=>"WinMailslotObj",
    "http://cybox.mitre.org/objects#WinMemoryPageRegionObject-2"=>"WinMemoryPageRegionObj",
    "http://cybox.mitre.org/objects#WinMutexObject-2"=>"WinMutexObj",
    "http://cybox.mitre.org/objects#WinNetworkRouteEntryObject-2"=>"WinNetworkRouteEntryObj",
    "http://cybox.mitre.org/objects#WinNetworkShareObject-2"=>"WinNetworkShareObj",
    "http://cybox.mitre.org/objects#WinPipeObject-2"=>"WinPipeObj",
    "http://cybox.mitre.org/objects#WinPrefetchObject-2"=>"WinPrefetchObj",
    "http://cybox.mitre.org/objects#WinVolumeObject-2"=>"WinVolumeObj",
    "http://cybox.mitre.org/objects#WinProcessObject-2"=>"WinProcessObj",
    "http://cybox.mitre.org/objects#WinRegistryKeyObject-2"=>"WinRegistryKeyObj",
    "http://cybox.mitre.org/objects#WinSemaphoreObject-2"=>"WinSemaphoreObj",
    "http://cybox.mitre.org/objects#WinServiceObject-2"=>"WinServiceObj",
    "http://cybox.mitre.org/objects#WinSystemObject-2"=>"WinSystemObj",
    "http://cybox.mitre.org/objects#WinSystemRestoreObject-2"=>"WinSystemRestoreObj",
    "http://cybox.mitre.org/objects#WinTaskObject-2"=>"WinTaskObj",
    "http://cybox.mitre.org/objects#WinThreadObject-2"=>"WinThreadObj",
    "http://cybox.mitre.org/objects#WinUserAccountObject-2"=>"WinUserAccountObj",
    "http://cybox.mitre.org/objects#WinWaitableTimerObject-2"=>"WinWaitableTimerObj",
    "http://cybox.mitre.org/objects#X509CertificateObject-2"=>"X509CertificateObj",
    "http://stix.mitre.org/Campaign-1"=>"campaign",
    "http://stix.mitre.org/common-1"=>"stixCommon",
    "http://data-marking.mitre.org/Marking-1"=>"marking",
    "http://stix.mitre.org/CourseOfAction-1"=>"coa",
    "http://stix.mitre.org/ExploitTarget-1"=>"et",
    "http://stix.mitre.org/Incident-1"=>"incident",
    "http://stix.mitre.org/Indicator-2"=>"indicator",
    "http://stix.mitre.org/stix-1"=>"stix",
    "http://stix.mitre.org/default_vocabularies-1"=>"stixVocabs",
    "http://stix.mitre.org/ThreatActor-1"=>"ta",
    "http://stix.mitre.org/TTP-1"=>"ttp",
    "http://stix.mitre.org/extensions/Address#CIQAddress3.0-1"=>"stixCiqAddress",
    "http://stix.mitre.org/extensions/AP#CAPEC2.6-1"=>"stixCapec",
    "http://stix.mitre.org/extensions/Identity#CIQIdentity3.0-1"=>"stixCiqIdentity",
    "http://stix.mitre.org/extensions/Malware#MAEC4.0-1"=>"stixMaec",
    "http://data-marking.mitre.org/extensions/MarkingStructure#Simple-1"=>"simpleMarking",
    "http://data-marking.mitre.org/extensions/MarkingStructure#TLP-1"=>"tlpMarking",
    "http://stix.mitre.org/extensions/StructuredCOA#Generic-1"=>"genericStructuredCOA",
    "http://stix.mitre.org/extensions/TestMechanism#Generic-1"=>"genericTM",
    "http://stix.mitre.org/extensions/TestMechanism#OpenIOC2010-1"=>"openiocTM",
    "http://stix.mitre.org/extensions/TestMechanism#OVAL5.10-1"=>"ovalTM",
    "http://stix.mitre.org/extensions/TestMechanism#Snort-1"=>"snortTM",
    "http://stix.mitre.org/extensions/TestMechanism#YARA-1"=>"yaraTM",
    "http://stix.mitre.org/extensions/Vulnerability#CVRF-1"=>"stixCvrf",
    "urn:oasis:names:tc:ciq:xpil:3"=>"xpil",

    'http://www.w3.org/2001/XMLSchema-instance'=>'xsi',
    'http://www.w3.org/2001/XMLSchema'=>'xsd'
  }
end
