// § uninstProgBodyAsUninstIface439
program prg;
int q[$]; int d[];
initial begin d = new[3]; foreach (q[i]) q[i] = i; foreach (d[j]) d[j] = j; end
endprogram
