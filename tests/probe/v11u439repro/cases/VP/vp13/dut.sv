// § uninstProgBodyAsUninstIface439
program prg;
int arr[4];
int x;
initial begin : blk
  int t;
  t = 5;
  foreach (arr[i]) arr[i] = t + i;
  x = t;
end
endprogram
