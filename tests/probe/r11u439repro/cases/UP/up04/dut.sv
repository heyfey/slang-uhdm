// § uninstProgSubBodyAsUninstIface439
program prg;
int arr[4];
task automatic fill();
  foreach (arr[k]) arr[k] = k;
endtask
initial fill();
endprogram
