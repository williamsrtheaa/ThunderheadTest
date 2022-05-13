    $startDate = (Get-Date -Day 1)#.AddMonths(-1)
    #$startDate = Get-Date -Day 1 -Hour 0 -Minute 0 -Second 0 -Millisecond 0
    $endDate = ($startDate).AddDays(15)
    $publicFolder = 'I:\Document Snap Checks'change
    $prodFolder = 'D:\aascripts\ReportingScripts\docSnapCheck\test'
    #$testFolder = 'I:\Document Snap Checks\TEST'

$csvList1 = Import-Csv -Path 'D:\aascripts\ReportingScripts\docSnapCheck\latest_doc_check_list_Motor_Home_Mem.csv'
foreach($oneItem in $csvList1)
        {
            $sourcePath = $oneItem.'sourcePath'
            $batchName = $oneItem.'batchName'
            $product = $oneItem.'product'
            $transaction = $oneItem.'transaction'
            $productType = $oneItem.'productType'
            $paymentType = $oneItem.'paymentType'
            $paymentMethod = $oneItem.'paymentMethod'
            
            Invoke-Expression "D:\aascripts\ReportingScripts\docSnapCheck\latestDocCheck_Motor_Home_Mem.ps1 $sourcePath $batchName $product $transaction $productType $paymentType $paymentMethod $startDate $endDate $publicFolder $prodFolder" -OutVariable out | Tee-Object -Variable out
            
        }

$csvList2 = Import-Csv -Path 'D:\aascripts\ReportingScripts\docSnapCheck\latest_doc_check_list_Travel.csv'
foreach($twoItem in $csvList2)
        {
            $sourcePath = $twoItem.'sourcePath'
            $batchName = $twoItem.'batchName'
            $product = $twoItem.'product'
            $transaction = $twoItem.'transaction'
            $productType = $twoItem.'productType'
            $paymentType = $twoItem.'paymentType'
            $paymentMethod = $twoItem.'paymentMethod'
            $transType = $twoItem.'transType'
                        
            Invoke-Expression "D:\aascripts\ReportingScripts\docSnapCheck\latestDocCheck_Travel.ps1 $sourcePath $batchName $product $transaction $productType $paymentType $paymentMethod $transType $startDate $endDate $publicFolder $prodFolder" -OutVariable out | Tee-Object -Variable out
        }

$csvList3 = Import-Csv -Path 'D:\aascripts\ReportingScripts\docSnapCheck\latest_doc_check_list_HomeLegacy_HM.csv'
foreach($threeItem in $csvList3)
        {
            $sourcePath = $threeItem.'sourcePath'
            $batchName = $threeItem.'batchName'
            $product = $threeItem.'product'
            $transaction = $threeItem.'transaction'
            $productType = $threeItem.'productType'
            $paymentType = $threeItem.'paymentType'
            $paymentMethod = $threeItem.'paymentMethod'
            $transType = $threeItem.'transType'
            
            Invoke-Expression "D:\aascripts\ReportingScripts\docSnapCheck\latestDocCheck_Legacy_HM.ps1 $sourcePath $batchName $product $transaction $productType $paymentType $paymentMethod $transType $startDate $endDate $publicFolder $prodFolder" -OutVariable out | Tee-Object -Variable out
            
        }   

 
