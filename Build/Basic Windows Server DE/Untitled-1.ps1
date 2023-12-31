

$command = 'Rename-Computer -NewName "LAB-RODC01" -Restart'
$Node = "pve01"
$VMID = 401

$RunCommand = New-PveNodesQemuAgentExec -Command "powershell.exe" -InputData "$command" -Vmid $VMID -Node $Node
$RunCommand.StatusCode

$ProcessID = ($RunCommand.Response.data).pid


$ExecStatus = get-pveNodesQemuAgentExecStatus -Vmid $VMID -Node $Node -Pid_ $ProcessID
$ExecStatus.StatusCode
$ExecStatus.Response.data.exited
$ExecStatus.Response.data.'out-data'