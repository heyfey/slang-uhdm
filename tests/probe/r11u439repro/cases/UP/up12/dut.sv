// § uninstProgSubBodyAsUninstIface439
program prg;
int arr[4];
function automatic int sum();
  int s = 0;
  foreach (arr[k]) s += arr[k];
  return s;
endfunction
initial $display(sum());
endprogram
