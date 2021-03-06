#***************************************************************************************
# This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
# THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
# TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS for A PARTICULAR PURPOSE.  We grant You a nonexclusive, royalty-free right to use and modify 
# the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or 
# trademarks to market Your software product in which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in 
# which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, 
# including attorneys fees, that arise or result from the use or distribution of the Sample Code.
#
# This script creates config and runs Set-DscLocalConfigurationManager on all nodes from $ConfigDataFile, as well if using Self signed cert it will deploy Root Chain to all nodes as well
#
# -Run this script as a local server Administrator
# -Run this script from elevaed prompt
# 
# Don't forget to: Set-ExecutionPolicy RemoteSigned
#
# Written by Chris Weaver (christwe@microsoft.com)
#
#****************************************************************************************

@{
    AllNodes = @(
        @{
            NodeName                    = "*"
            DisableIISLoopbackCheck     = $true
            PSDscAllowPlainTextPassword = $true
            PSDscAllowDomainUser        = $true
            InstallPrereqs              = $true
            InstallSharePoint           = $true
          },
        @{ 
            NodeName                    = "SP2016APP01"
            FirstServer                 = $true
            MinRole                     = "Custom"#https://technet.microsoft.com/en-us/library/mt667910(v=office.16).aspx, https://msdn.microsoft.com/en-us/library/office/microsoft.sharepoint.administration.spserverrole.aspx
            CentralAdminHost            = $true
            PowerShellServer            = $true
            CustomServices = @{  
                WebFrontEnd             = $false
                DistributedCache        = $false
                AppManagement           = $False
                BCS                     = $False
                SubScriptionSettings    = $false
                SecureStore             = $False
                UserProfile             = $true
                WorkFlowTimer           = $false
                ManagedMetadata         = $true
                VisioGraphics           = $false
                Search                  = $true
            }
          },
          @{ 
            NodeName                    = "SP2016APP02"
            FirstServer                 = $false
            MinRole                     = "ApplicationWithSearch"#https://technet.microsoft.com/en-us/library/mt667910(v=office.16).aspx
            CentralAdminHost            = $false
            PowerShellServer            = $false
            CustomServices = @{  
                WebFrontEnd             = $false
                DistributedCache        = $false
                AppManagement           = $False
                BCS                     = $False
                SubScriptionSettings    = $false
                SecureStore             = $False
                UserProfile             = $false
                WorkFlowTimer           = $false
                ManagedMetadata         = $false
                VisioGraphics           = $false
                Search                  = $false
            }
          },
        @{ 
            NodeName                    = "SP2016WFE01"
            FirstServer                 = $false
            MinRole                     = "WebFrontEndWithDistributedCache"
            CentralAdminHost            = $false
            PowerShellServer            = $false
            CustomServices = @{  
                WebFrontEnd             = $false
                DistributedCache        = $false
                AppManagement           = $False
                BCS                     = $False
                SubScriptionSettings    = $false
                SecureStore             = $False
                UserProfile             = $false
                WorkFlowTimer           = $false
                ManagedMetadata         = $false
                VisioGraphics           = $false
                Search                  = $false
            }
          },
          @{ 
            NodeName                    = "SP2016WFE02"
            FirstServer                 = $false
            MinRole                     = "WebFrontEndWithDistributedCache"
            CentralAdminHost            = $false
            PowerShellServer            = $false
            CustomServices = @{  
                WebFrontEnd             = $false
                DistributedCache        = $false
                AppManagement           = $False
                BCS                     = $False
                SubScriptionSettings    = $false
                SecureStore             = $False
                UserProfile             = $false
                WorkFlowTimer           = $false
                ManagedMetadata         = $false
                VisioGraphics           = $false
                Search                  = $false
            }
          }
    )
    NonNodeData = @{
        DSCConfig = @{
            DSCConfigPath               = "C:\_DSCConfig"
            #DSCConfigModulePath         = "C:\_DSCConfig\Modules" 
            DSCConfigServiceEndPoint    = "https://dscserver.weaver.ad:8080/PSDSCPullServer.svc"  #Url for DSC service
            DSCConfigSharePath          = "\\DSC01\_DSCConfig" #Removed \Configuration
            DSCConfigModuleOnline       = $true                 #If the DSC server has internet access set this to true
            DSCLocalFolder              = "C:\_DSCOutput"       #This must exist on client machines
           # DSCConfigModuleShare        = "\\dsc01\DSCConfig\Modules"
            DSCServicePhysicalPath      = "$env:SystemDrive\inetpub\DSCPullServer" 
            DSCUseSecurityBestPractices = $true
            DSCAcceptSelfSignedCertificates = $true
            DSCConfigRegistryKey = "b2d9d288-fd87-4b26-9761-e211fd9a13d7"
            DSCCOnfigRegistryKeyFile = "C:\_RegistrationKey"     # This folder should be seperate from others, DSC process will create
            InstalledModules = @("xSystemSecurity","xPendingReboot","SharePointDsc","xWebAdministration","xCredSSP","xDscDiagnostics","xPSDesiredStateConfiguration","SharePointPnPPowerShell2016")
        }
        CreateFolders = @(
            @{
                Path = "C:\Scripts"
            },
            @{
                Path = "C:\Weaver"
            }
        )
        FilesandFolders = @(
       <#     @{
                Type = "Directory" # Enter Directory or File
                Ensure = "Present" # If you set to Present it will create, if set to absent it will delete
                Recurse = $true # if $true ensures presence of subdirectories, too
                Source = "C:\Users\Public\Documents\DSCDemo\DemoSource\"
                Destination = "C:\Users\Public\Documents\DSCDemo\DemoDestination"
                Force = $true
                MatchSource = $false    # Will match the source and destination folder when DSC runs
            };
            @{
                Type = "Directory" # Enter Directory or File
                Ensure = "Present" # If you set to Present it will create, if set to absent it will delete
                Recurse = $true # if $true ensures presence of subdirectories, too
                Source = "C:\Users\Public\Documents\DSCDemo\DemoSource\"
                Destination = "C:\Users\Public\Documents\DSCDemo\DemoDestination"
                Force = $true
                MatchSource = $True
            } #>
        )
        DomainDetails = @{
            DomainName                  = "weaver.ad"
            NetbiosName                 = "weaver"
        }
        SQLServer = @{
            ContentDatabaseServer       = "sqlalias.weaver.ad\SHAREPOINT"
            SearchDatabaseServer        = "sqlalias.weaver.ad\SHAREPOINT"
            ServiceAppDatabaseServer    = "sqlalias.weaver.ad\SHAREPOINT"
            FarmDatabaseServer          = "sqlalias.weaver.ad\SHAREPOINT"
        }
        SharePoint = @{
            Version                     = 2016
            Installation = @{
                InstallKey              = "TY6N4-K9WD3-JD2J2-VYKTJ-GVJ2J"
                BinaryDir               = "\\DSC01\_DSCShare\SP2016Bits"
                PrereqInstallerPath     = "\\DSC01\_DSCShare\SP2016bits\prerequisiteinstallerfiles"
                PrereqInstallMode       = $true
<#
                Update = @{
                    UpdateFile           = "\\DSC01\DSCShare\SP2016Updatebits\SharePointUpdate.exe"
                    StopServices        = $false                                            #Causes outage but faster install of bits Currently doesnt work with SP2016
                    InstallDate         = "mon", "tue", "wed", "thu", "fri", "sat", "sun" 
                    InstallTime         = "00:01am to 11:59pm"
                }
                ConfigWizard = @{
                    RunDays             = "mon", "tue", "wed", "thu", "fri", "sat", "sun"
                    RunTime             = "00:01am to 11:59pm"
                }
#>
            }
            Farm = @{
                ConfigurationDatabase   = "SP_Config"
                AdminContentDatabase    = "SP_Admin_Content"
                CentralAdminPort        = 5000
                CentralAdminAuth        = "NTLM"       #Valid values are "NTLM" or "Kerberos"
                FarmAdmins              = @("WEAVER\administrator","WEAVER\christwe")            #Do not add farm account, script will take care of that in background
            }
         
            # You can have only one of each kind except for 'ConnectionAccount' which you can have multiple leave @() in place even if you only have one account
            ServiceAccounts = @{
                SetupAccount            = "WEAVER\sp2016setupacct"
                FarmAccount             = "WEAVER\sp2016farmacct"
                WebAppPoolAccount       = "WEAVER\sp2016webpoolacct"
                ServicesAppPoolAccount  = "WEAVER\sp2016apppoolacct"
                ContentAccessAccount    = "WEAVER\sp2016crawlacct"
               # ConnectionAccount       = @("WEAVER\spconnacct")
                ManagedAccountPasswordResetSettings = @{  
                        AdministratorMailAddress      = "sharepointadmin@weaver.ad"
                        SendmessageDaysBeforeExpiry   = "14"
                        PasswordChangeTimeoutinSec    = "60"
                        PasswordChangeNumberOfRetries = "3"
                }
            }
            DiagnosticLogs = @{
                Path                                        = "C:\ULSLogs"
                MaxSizeGB                                   = 1
                DaysToKeep                                  = 1
                AppAnalyticsAutomaticUploadEnabled          = $false
                CustomerExperienceImprovementProgramEnabled = $true
                DownloadErrorReportingUpdatesEnabled        = $false
                ErrorReportingAutomaticUploadEnabled        = $false
                ErrorReportingEnabled                       = $false
                EventLogFloodProtectionEnabled              = $true
                EventLogFloodProtectionNotifyInterval       = 5
                EventLogFloodProtectionQuietPeriod          = 2
                EventLogFloodProtectionThreshold            = 5
                EventLogFloodProtectionTriggerPeriod        = 2
                LogCutInterval                              = 15
                LogMaxDiskSpaceUsageEnabled                 = $true
                ScriptErrorReportingDelay                   = 30
                ScriptErrorReportingEnabled                 = $true
                ScriptErrorReportingRequireAuth             = $true
            }
            UsageLogs = @{
                DatabaseName            = "SP_Usage"
                Path                    = "C:\UsageLogs"
            }
            Services = @{
                ApplicationPoolName     = "SharePoint Service Applications"
            }
            StateService = @{
                Name                    = "State Service Application"
                DatabaseName            = "SP_State"
            }
            WebApplications = @(
                  @{
                    UseClassic          = $false
                    Name                = "SharePoint"
                    DatabaseName        = "SP_Content_DB001"
                    Url                 = "http://sp.weaver.ad"
                  #  Authentication      = "NTLM"
                    Anonymous           = $false
                  #  UseSSL              = $false
                    BindingHostHeader   = "sp.weaver.ad"
                    WebPort             = 80
                    AppPool             = "Web App Pool"
                    AppPoolAccount      = "WEAVER\sp2016apppoolacct"
                    SuperUser           = "WEAVER\sp2016superuser"
                    SuperReader         = "WEAVER\sp2016superreader"
                    UseHostNamedSiteCollections = $false
                    MaximumUploadSize   = 1024
                    ManagedPaths = @(
                        @{
                            Path        = "sites"
                            Explicit    = $false
                        },
                        @{
                            Path        = "search"
                            Explicit    = $true
                        }
                    )
                  },
                  @{
                    Name                = "MySites"
                    DatabaseName        = "MySites_Content_DB001"
                    Url                 = "http://mysites.weaver.ad"
                    Authentication      = "NTLM"
                    Anonymous           = $false
                    UseSSL              = $false
                    BindingHostHeader   = "mysites.weaver.ad"
                    WebPort             = 80
                    AppPool             = "Web App Pool"
                    AppPoolAccount      = "WEAVER\sp2016apppoolacct"
                    SuperUser           = "WEAVER\sp2016superuser"
                    SuperReader         = "WEAVER\sp2016superreader"
                    UseHostNamedSiteCollections = $false
                    MaximumUploadSize   = 1024
                    ManagedPaths = @(
                        @{
                            Path        = "my"
                            Explicit    = $true
                        }
                    )
                    SiteCollections = @(
                        @{
                            Url         = "http://mysites.weaver.ad/"
                            Owner       = "Weaver\sp2016farmacct"
                            Name        = "My Site Host"
                            Template    = "SPSMSITEHOST#0"
                            Database    = "Mysites_Content_DB001"
                            HostNamedSiteCollection = $false
                        }
                    )
                  },
                @{
                    Name                = "ECM"
                    DatabaseName        = "ECM_Content_DB001"
                    Url                 = "http://ecm.weaver.ad"
                    Authentication      = "NTLM"
                    Anonymous           = $false
                    UseSSL              = $false
                    BindingHostHeader   = "ecm.weaver.ad"
                    WebPort             = 80
                    AppPool             = "Web App Pool"
                    AppPoolAccount      = "WEAVER\sp2016apppoolacct"
                    SuperUser           = "WEAVER\sp2016superuser"
                    SuperReader         = "WEAVER\sp2016superreader"
                    UseHostNamedSiteCollections = $false
                    MaximumUploadSize   = 1024
                    ManagedPaths = @(
                        @{
                            Path        = "projects"
                            Explicit    = $false
                        }
                     )
                   }
            )
            UserProfileService = @{
                Name                    = "User Profile Service Application"
                ProxyName               = "User Profile Service Application Proxy"
                NetbiosEnable           = $false
                MySiteUrl               = "http://mysites.weaver.ad/"
                ProfileDB               = "SP_UPA_Profile"
                SocialDB                = "SP_UPA_Social"
                SyncDB                  = "SP_UPA_Sync"
                UseADImport             = $true
                UserProfileSyncConnection = @(
                    @{
                        Forest = "weaver.ad"
                        Domain = "weaver"  #only for SP2016
                        Name = "Weaver Domain"
                        ConnectionUsername = "WEAVER\SPConnAcct"
                        Server = "" #Best to leave blank but you can add a server if that is better for your architecture
                        UseSSL = $false
                        IncludedOUs = @("OU=Users,OU=Enterprise,DC=weaver,DC=ad")
                        ExcludedOUs = @("OU=Service Accounts,OU=Enterprise,DC=weaver,DC=ad") #Not supported in SP2016
                        Force = $false
                    }
                )
            }
            SecureStoreService = @{
                Name                    = "Secure Store Service Application"
                DatabaseName            = "SP_SecureStore"
                AuditLogMaxSize         = 30
                AuditingEnabled         = $true
            }
            ManagedMetadataService = @{
                Name                    = "Managed Metadata Service Application"
                DatabaseName            = "SP_MMS"
            }
            BCSService = @{
                Name                    ="BCS Service Application" 
                DatabaseName            = "SP_BCS"
            }
            Search = @(
            @{
                Name                    = "Search Service Application"
                DatabaseName            = "SP_Search"
                CloudSSA                = $false
                SearchTopology = @{
                    Admin               = @("SP2016APP01")
                    Crawler             = @("SP2016APP01")
                    ContentProcesing    = @("SP2016APP01";"SP2016APP02")
                    AnalyticsProcesing = @("SP2016APP01")
                    QueryProcesing      = @("SP2016APP01")
                    IndexPartition0      = @("SP2016APP01")
                    IndexPartition0Folder = "C:\searchindex\0"
                    IndexPartitions = @(
                        @{
                            Index = 1       #Starting from 1 increment for each additional partition
                            Servers = @("SP2016APP02")
                            IndexPartitionFolder = "C:\SearchIndex\1"
                        }
                    )
                }
            <#    SearchContentSource = @(       #Can use this to help with schedules https://www.powershellgallery.com/packages/SharePointDSC/1.0.0.0/Content/DSCResources%5CMSFT_SPSearchContentSource%5CMSFT_SPSearchContentSource.schema.mof
                    @{                         # Currently only support ContentSourceType 'SharePoint"
                        Name                 = "Collab and ECM Content"
                        ServiceAppName       = "Search Service Application"
                        ContentSourceType    = "SharePoint"           #Possible values SharePoint, Website, or FileShare
                        Addresses            = @("http://sp.weaver.ad","http://ecm.weaver.ad")
                        CrawlSetting         = "CrawlEverything"      #Possible values CrawlEverything, CrawlFirstOnly, Custom
                        ContinuousCrawl      = $true
                        IncrementalSchedule  = @{        #Set to $null if you don't want to set a schedule
                            ScheduleType = "Daily"       #Can be set to None, Daily, Weekly, Monthly
                            StartHour = "0"
                            StartMinute = "0"
                            CrawlScheduleRepeatDuration = "1440"
                            CrawlScheduleRepeatInterval = "5"
                        }
                        FullSchedule         = @{
                            ScheduleType = "Weekly"
                            CrawlScheduleDaysOfWeek = @("Everyday")     #Everyday is also acceptable value
                            StartHour = "3"
                            StartMinute = "0"
                        }
                        Priority             = "Normal"               #Possible values Normal or High
                    },
                    @{
                        Name                 = "Social Content"
                        ServiceAppName       = "Search Service Application"
                        ContentSourceType    = "SharePoint"
                        Addresses            = @("http://mysites.weaver.ad")
                        CrawlSetting         = "CrawlEverything"
                        ContinuousCrawl      = $true
                        IncrementalSchedule  =  $null
                        FullSchedule         = @{
                            ScheduleType = "Monthly"
                            CrawlScheduleDaysofMonth = 15
                            CrawlScheduleMonthsofYear = @("AllMonths")
                            StartHour = "3"
                            StartMinute = "0"
                        }
                        Priority             = "Normal"
                    }
                )#>
            }
            )
            OutgoingEmail = @(            #Note if you want to set farm wide then WebAppUrl needs to be set to CA, if you want you can also set to WebApp or both
                @{
                    WebAppUrl               = "http://sp2016app01:5000"
                    SMTPServer              = "internalmail.weaver.ad"
                    FromAddress             = "sharepointadmin@weaver.ad"
                    ReplyToAddress          = "sharepointadmin@weaver.ad"
                    CharacterSet            = "65001"
                },
                @{
                    WebAppUrl               = "http://sp.weaver.ad"
                    SMTPServer              = "internalmail.weaver.ad"
                    FromAddress             = "sharepointadmin@weaver.ad"
                    ReplyToAddress          = "sharepointadmin@weaver.ad"
                    CharacterSet            = "65001"
                }
            )
            InboundEmail = @{
                Enable = $true
                EmailDomain = "sharepoint.weaver.ad"
            }
            DCache = @{
                CacheSizeInMB           = 2048
            }
            AppManagementService = @{
                Name                    = "Application Management Service Application"
                DatabaseName            = "SP_AppManagement"
            }
            SubscriptionSettingsService = @{
                Name                    = "Subscription Settings Service Application"
                DatabaseName            = "SP_SubscriptionSettings"
            }
            VisioService = @{
                Name                    = "Visio Service Application"
            }
            WordAutomationService = @{
                Name                    = "Word Automation Service Application"
                DatabaseName            = "SP_WordAutomation"
            }
        }
     }
 }