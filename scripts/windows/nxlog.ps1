  $client = new-object System.Net.WebClient
  $client.DownloadFile('https://nxlog.co/system/files/products/files/348/nxlog-ce-2.10.2102.msi', 'c:\nxlog-ce-2.10.2102.msi')

  cd c:\
  msiexec /qn nxlog-ce-2.10.2102.msi

  echo ## > C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo ## This is a sample configuration file. See the nxlog reference manual about the >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo ## configuration options. It should be installed locally and is also available >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo ## online at http://nxlog.org/nxlog-docs/en/nxlog-reference-manual.html >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo ## Please set the ROOT to the folder your nxlog was installed into, >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo ## otherwise it will not start. >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo #define ROOT C:\Program Files\nxlog >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo define ROOT C:\Program Files (x86)\nxlog >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo Moduledir %ROOT%\modules >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo CacheDir %ROOT%\data >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo Pidfile %ROOT%\data\nxlog.pid >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo SpoolDir %ROOT%\data >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo LogFile %ROOT%\data\nxlog.log >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo <Extension exec> >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo     Module  xm_exec >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo </Extension> >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo <Extension syslog> >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo     Module  xm_syslog >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo </Extension> >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo <Extension json> >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo     Module  xm_json >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo </Extension> >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo <Input eventlog> >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo   # Uncomment for Windows Vista/2008 or later  >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo   Module im_msvistalog  >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo   # Uncomment for Windows 2000 or later >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo   # Module im_mseventlog >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo   ReadFromLast TRUE >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo   SavePos     TRUE >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo   Query     <QueryList> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                       <Query Id="0"> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf                
  echo                                                                                                      <Select Path="Security">*[System[(EventID=1100)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4768)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4769)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4771)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4616)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4624)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4625)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4634)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4647)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4648)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4656)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4719)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4720)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4722)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4723)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4724)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4725)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4726)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4727)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4728)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4729)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4730)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4731)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4732)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4733)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4734)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4735)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4737)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4738)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4739)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4740)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4741)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4742)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4743)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4744)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4745)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4748)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4749)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4750)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4753)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4754)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4755)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4756)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4758)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4759)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4760)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4763)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4764)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4767)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4778)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4783)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4800)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Security">*[System[(EventID=4801)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                   <Select Path="System">*[System[(EventID=7036)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Application">*[System[(EventID=18454)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                                      <Select Path="Application">*[System[(EventID=18456)]]</Select> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo                                                                                       </Query> \ >> C:\Program Files (x86)\nxlog\conf\nxlog.conf   
  echo                                          </QueryList>  >> C:\Program Files (x86)\nxlog\conf\nxlog.conf                                                           
  echo </Input> >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo <Output syslogout> >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo     Module      om_file >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo     File        'c:\CustomLogs\syslog.log' >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo     CreateDir   TRUE >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo     Exec to_syslog_bsd(); >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
 echo     <Exec> >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo         if syslogout->file_size() > 5M >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo         { >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo             $newfile = "c:\CustomLogs\syslog" + "_" + strftime(now(), "%Y%m%d%H%M%S") + ".log"; >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo             syslogout->rotate_to($newfile); >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo         } >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo     </Exec> >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo </Output> >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo <Route 1> >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo     Path        eventlog => syslogout >> C:\Program Files (x86)\nxlog\conf\nxlog.conf
  echo </Route> >> C:\Program Files (x86)\nxlog\conf\nxlog.conf

  net start nxlog
