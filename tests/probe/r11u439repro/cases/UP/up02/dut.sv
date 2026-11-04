// § uninstProgBodyAsUninstIface439
program prg;
int x, y;
int arr[4];
initial begin x = y; foreach (arr[i]) x += arr[i]; end
endprogram
