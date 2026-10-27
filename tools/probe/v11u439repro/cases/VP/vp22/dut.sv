// § uninstProgSubBodyAsUninstIface439
program prg;
int a[2][3];
task automatic t(); foreach (a[, j]) a[0][j] = j; endtask
initial t();
endprogram
