function get-input-TextBox{
	Add-Type -AssemblyName System.Windows.Forms
	Add-Type -AssemblyName System.Drawing
	
    Function choose-csv-header-from-list{
        # User will be presented a list of headers from their selected CSV file
        # and asked which head data should be pulled from
        param([array] $ChsfCsvHeaders)
         # Form settings
        $CsvHeaderSelectForm = New-Object System.Windows.Forms.Form
        $CsvHeaderSelectForm.Text = 'Column Selection'
        $CsvHeaderSelectForm.Size = New-Object System.Drawing.Size(350,400)
        $CsvHeaderSelectForm.StartPosition = 'CenterScreen'
        $CsvHeaderSelectForm.FormBorderStyle = 'FixedToolWindow'
        $CsvHeaderSelectForm.Topmost = $true


        # Okay button settings
        $ChsfOkButton = New-Object System.Windows.Forms.Button
        $ChsfOkButton.Location = New-Object System.Drawing.Point(50,325)
        $ChsfOkButton.Size = New-Object System.Drawing.Size(75,27)
        $ChsfOkButton.Text = 'Okay'
        $ChsfOkButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $CsvHeaderSelectForm.AcceptButton = $ChsfOkButton
        $CsvHeaderSelectForm.Controls.Add($ChsfOkButton)

        
        # Cancel button settings
        $ChsfCancelButton = New-Object System.Windows.Forms.Button
        $ChsfCancelButton.Location = New-Object System.Drawing.Point(210,325)
        $ChsfCancelButton.Size = New-Object System.Drawing.Size(75,27)
        $ChsfCancelButton.Text = 'Cancel'
        $ChsfCancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $CsvHeaderSelectForm.CancelButton = $ChsfCancelButton
        $CsvHeaderSelectForm.Controls.Add($ChsfCancelButton)


        # Label settings
        $ChsfLabel = New-Object System.Windows.Forms.Label
        $ChsfLabel.Location = New-Object System.Drawing.Point(10,10)
        $ChsfLabel.Size = New-Object System.Drawing.Size(330,30)
        $ChsfLabel.Text = "Select the column that should be used"
        $CsvHeaderSelectForm.Controls.Add($ChsfLabel)


        # Selection list settings
        $ChsfSelectionList = New-Object System.Windows.Forms.ListBox
        $ChsfSelectionList.Location = New-Object System.Drawing.Point(10,40)
        $ChsfSelectionList.Size = New-Object System.Drawing.Size(325,280)
        $ChsfSelectionList.Font = 'Consolas, 14pt'
        foreach($ChsfCsvHeaderName in $ChsfCsvHeaders){
            [void] $ChsfSelectionList.Items.Add($ChsfCsvHeaderName)}
        $CsvHeaderSelectForm.Controls.Add($ChsfSelectionList)
        
        
        # Show the window on the screen
        $ChsfResults = $CsvHeaderSelectForm.ShowDialog()
        if ($ChsfResults -eq [System.Windows.Forms.DialogResult]::OK){return $ChsfSelectionList.SelectedItem}
        else{return $null}
        }

	# Form settings
	$Form = New-Object System.Windows.Forms.Form 
	$Form.Text = "Data Entry Form"
	$Form.Size = New-Object System.Drawing.Size(500,580) 
    $Form.FormBorderStyle = 'FixedToolWindow'
	$Form.StartPosition = "CenterScreen"
	$Form.Topmost = $True
	

	# Okay Button settings
	$OKButton = New-Object System.Windows.Forms.Button
	$OKButton.Location = New-Object System.Drawing.Point(10,510)
	$OKButton.Size = New-Object System.Drawing.Size(75,27)
	$OKButton.Text = "Okay"
	$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
	$Form.AcceptButton = $OKButton
	$Form.Controls.Add($OKButton)
	

	# Cancel Button settings
	$CancelButton = New-Object System.Windows.Forms.Button
	$CancelButton.Location = New-Object System.Drawing.Point(110,510)
	$CancelButton.Size = New-Object System.Drawing.Size(75,27)
	$CancelButton.Text = "Cancel"
	$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
	$Form.CancelButton = $CancelButton
	$Form.Controls.Add($CancelButton)
    

    # Get input from a file button settings
    $GetInputFromFileWindow = New-Object System.Windows.Forms.Button
    $GetInputFromFileWindow.Location = New-Object System.Drawing.Size(300,510)
    $GetInputFromFileWindow.Size = New-Object System.Drawing.Size(170,27)
    $GetInputFromFileWindow.Text = "Get Input From File"
    $GetInputFromFileWindow.Add_Click({    
		$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.initialDirectory = $env:USERPROFILE
        $OpenFileDialog.filter = "Text file (*.txt)|*.txt|CSV (*.csv)|*.csv"
        $OpenFileDialog.ShowDialog() | Out-Null
        if($OpenFileDialog.filename -like '*.csv'){
            $InputCsvFile = Import-Csv -Path $OpenFileDialog.filename
            $CsvHeaders = @()
            $CsvHeaders += (Get-Member -InputObject $InputCsvFile[0] -MemberType NoteProperty).name
            $ChosenCsvHeader = choose-csv-header-from-list -ChsfCsvHeaders $CsvHeaders
            Remove-Variable -Name CsvHeaders
            if(-not($ChosenCsvHeader -eq $null)){
                $CsvDataArray = @()
                $InputCsvFile | %{$CsvDataArray += $_.$ChosenCsvHeader}
                $TextBox.text = $CsvDataArray -join "`r`n"
                Remove-Variable -Name CsvDataArray 
                Remove-Variable -Name InputCsvFile 
                Remove-Variable -Name ChosenCsvHeader
                }
            }
        elseif(-not($OpenFileDialog.filename -eq $null)){
            $TextBox.text = (Get-Content -Path $OpenFileDialog.filename) -join "`r`n"
            }
        })
    $Form.Controls.Add($GetInputFromFileWindow)
	

	# Form label settings
	$label = New-Object System.Windows.Forms.Label
	$label.Location = New-Object System.Drawing.Point(10,10) 
	$label.Size = New-Object System.Drawing.Size(350,30) 
	$label.Text = "Please enter the information in the space below`r`nPress OK when done"
	$Form.Controls.Add($label) 
    

    # TextBox settings
	$TextBox = New-Object System.Windows.Forms.TextBox 
	$TextBox.Location = New-Object System.Drawing.Point(10,45) 
	$TextBox.Size = New-Object System.Drawing.Size(475,455)
    $TextBox.ScrollBars = "Vertical" 
	$TextBox.AcceptsReturn = $True
	$TextBox.Multiline = $True
    $TextBox.Font = 'Consolas, 14pt'
	$Form.Controls.Add($TextBox) 
	$Form.Add_Shown({$TextBox.Select()})


    # Show the Form/GUI
	$result = $Form.ShowDialog()
    
    # Check the input and parse it
	if ($result -eq [System.Windows.Forms.DialogResult]::OK){							# Settings for what happens when the user hits okay
        $FunctionReturn = @()															# Empty Array to store the user input that will be returned
        ($TextBox.Text).Replace("`r`n",",").split(",") | %{ 							# Convert the input into an array
        if(-Not ($_ -match '^\s*$')){$FunctionReturn += $_.Trim()}} 					# Remove leading and trailing white space and blank line
        if ($FunctionReturn.Length -eq 0){"YOU DIDN'T ENTER ANYTHING"}					# Kill the scrip if the user hits okay but does not enter anything
        return $FunctionReturn
	    }
    else{"YOU DIDN'T CLICK OK"} 														# Kill the script if the user does not hit okay
    }
get-input-TextBox