   ############################################SQL CONNECTION####################################################################
    $SQLServer = "mlh1aag02"
    #$SQLServer="MLH1SQLUAT01\THUAT"
    $SQLDBName = "Thunderhead"

    $SqlConnection = New-Object System.Data.SqlClient.SqlConnection
    $SqlConnection.ConnectionString = "Server = $SQLServer; Database = $SQLDBName;Connection Timeout=160; Integrated Security = SSPI; "
    $sqlConnection.Open()

    if ($sqlConnection.State -ne [Data.ConnectionState]::Open) 
    {
      "Connection to DB is not open."
      Exit
    }

    $SqlCmd = New-Object System.Data.SqlClient.SqlCommand
    $SqlCmd.Connection = $sqlConnection
        
    $SqlCmd.CommandType = [System.Data.CommandType]::StoredProcedure;
    $SqlCmd.CommandTimeout=600

    $SqlCmd.CommandText = 'dbo.aa_report_Doc_Snap_Check';
    
    $SqlCmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@startDate",[Data.SQLDBType]::DateTime))) | Out-Null
    $SqlCmd.Parameters[0].Value = $startDate;
    $SqlCmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@endDate",[Data.SQLDBType]::DateTime))) | Out-Null
    $SqlCmd.Parameters[1].Value = $endDate;
    $SqlCmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@batchName",[Data.SQLDBType]::NVARCHAR))) | Out-Null
    $SqlCmd.Parameters[2].Value = $batchName;
    $SqlCmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@productType",[Data.SQLDBType]::NVARCHAR))) | Out-Null
    $SqlCmd.Parameters[3].Value = $productType;
    $SqlCmd.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@paymentMethod",[Data.SQLDBType]::NVARCHAR))) | Out-Null
    $SqlCmd.Parameters[4].Value = $paymentMethod;

    $SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter 
    $SqlAdapter.SelectCommand = $SqlCmd
    $SqlAdapter.SelectCommand.CommandTimeout=360

    $DataSet = New-Object System.Data.DataSet 
    $SqlAdapter.Fill($DataSet) | Out-Null

    $sqlConnection.Close();
   ############################################################################################################################

    $mainArchiveDate = (Get-Date).AddDays(-3)
    
    foreach($sourceItem in $DataSet.Tables[0])
    {
        $source = $sourceItem.Membership_number
        Write-Host "source = " $source
        
        [datetime]$docDate = $sourceItem.TH_START_DATE

        $docYear = ($docDate).ToString('yyyy')
        $docMonth = ($docDate).ToString('MM')
        $docMonthName = (Get-Culture).DateTimeFormat.GetMonthName($docMonth)
        $docDay = ($docDate).ToString('%d')
        $dateTime  = ($docDate).ToString('ddMMyyyy')

        if($docDate -gt $mainArchiveDate)
        { 
            if ($source -like 'AAV*')
            {
                $sourceFolder = $sourcePath+'\'+$product+'\'+'Value'
            }
            else
            {
                $sourceFolder = $sourcePath+'\'+$product+'\'+'ExtStan'
            }
        }
        else
        {
            $sourceFolder = '\\aafs01\theadarchive\mainArchive'+'\'+$product+'\'+$docYear+'\'+$docMonthName+'\'+$docDay
        }

        $sourceSearch = $source+'*'
        $fileName = '\'+(Get-ChildItem -Path $sourceFolder -Recurse | Where-Object {(!$_.PsIsContainer) -and ($_.Name -like $sourceSearch) -and ($_.Name -like $transType) } | Select-Object -First 1)

        $destinationPublicFloder = $publicFolder+'\'+$docYear+'\'+$docMonthName+'\'+$product+'\'+$transaction
        $destinationProdFloder = $prodFolder+'\'+$docYear+'\'+$docMonthName+'\'+$product+'\'+$transaction
        #$destinationTestFloder = $testFolder+'\'+$docYear+'\'+$docMonthName+'\'+$product+'\'+$transaction
        
        $copySource = $sourceFolder+$fileName
        $copyPublicDestination = $destinationPublicFloder+'\'+$product+'_'+$transaction+'_'+$paymentType+'_'+$dateTime+'.ps'
        $copyProdDestination = $destinationProdFloder+'\'+$product+'_'+$transaction+'_'+$paymentType+'_'+$dateTime+'.ps'
        #$copyTestDestination = $destinationTestFloder+'\'+$product+'_'+$transaction+'_'+$paymentType+'_'+$dateTime+'.ps'
        
        if($copySource -eq $sourceFolder)
        {
            Write-Host "Could not find " $product+'_'+$transaction+'_'+$paymentType " in " $sourceFolder
        }
        else
        {
            <#
            ########COPY TO PUBLIC FOLDER##############
            if (Test-Path $copyPublicDestination)
                {
                    Write-Host "Copy of document already exists: " $copyPublicDestination
                }
            elseif (!(Test-Path $destinationPublicFloder))
                {
                    New-Item -Path $destinationPublicFloder -ItemType "directory"
                    Copy-Item -Path $copySource -Destination $copyPublicDestination -Force

                    Write-Host "Copy of document retrieved from: " $copySource
                    Write-Host "Copy saved successfully in: " $copyPublicDestination
                }
            else
                {
                    Copy-Item -Path $copySource -Destination $copyPublicDestination -Force

                    Write-Host "Copy of document retrieved from: " $copySource
                    Write-Host "Copy saved successfully in: " $copyPublicDestination
                }
             #>   
            ###########COPY TO PROD FOLDER##############
            if (Test-Path $copyProdDestination)
                {
                    Write-Host "Copy of document already exists: " $copyProdDestination
                }
            elseif (!(Test-Path $destinationProdFloder))
                {
                    New-Item -Path $destinationProdFloder -ItemType "directory"
                    Copy-Item -Path $copySource -Destination $copyProdDestination -Force

                    Write-Host "Copy of document retrieved from: " $copySource
                    Write-Host "Copy saved successfully in: " $copyProdDestination
                }
            else
                {
                    Copy-Item -Path $copySource -Destination $copyProdDestination -Force

                    Write-Host "Copy of document retrieved from: " $copySource
                    Write-Host "Copy saved successfully in: " $copyProdDestination
                }
             <#
            ###########COPY TO TEST FOLDER##############
            if (Test-Path $copyTestDestination)
                {
                    Write-Host "Copy of document already exists: " $copyTestDestination
                }
            elseif (!(Test-Path $destinationTestFloder))
                {
                    New-Item -Path $destinationTestFloder -ItemType "directory"
                    Copy-Item -Path $copyProdDestination -Destination $copyTestDestination -Force

                    Write-Host "Copy of document retrieved from: " $copySource
                    Write-Host "Copy saved successfully in: " $copyTestDestination
                }
            else
                {
                    Copy-Item -Path $copyProdDestination -Destination $copyTestDestination -Force

                    Write-Host "Copy of document retrieved from: " $copyProdDestination
                    Write-Host "Copy saved successfully in: " $copyTestDestination
                }
                #>
         }
    }