// § uninstProgBodyAsUninstIface439
program p1;
int arr[4];
initial foreach (arr[i]) arr[i] = i;
endprogram
program p2;
byte b[2];
initial foreach (b[n]) b[n] = n;
endprogram
