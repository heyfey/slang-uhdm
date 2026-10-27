// § uninstProgBodyAsUninstIface439
program prg;
int a[2]; int b[3];
initial foreach (a[i]) foreach (b[j]) b[j] = a[i] + j;
endprogram
