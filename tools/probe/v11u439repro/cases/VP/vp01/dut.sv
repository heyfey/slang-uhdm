// § uninstProgBodyAsUninstIface439
program prg;
int arr[4];
int x, y;
initial begin
  for (int k = 0; k < 4; k++) arr[k] = k;
  x = y + arr[1];
end
endprogram
