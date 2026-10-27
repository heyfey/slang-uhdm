// § uninstProgBodyAsUninstIface439
program prg;
int arr[2][3];
int s;
initial foreach (arr[i, j]) begin s = s + arr[i][j]; arr[i][j] = i * j; end
endprogram
