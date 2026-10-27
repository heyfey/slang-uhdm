// § uninstProgBodyAsUninstIface439
program prg;
int x;
function automatic int f(int a); return a + 1; endfunction
initial x = f(3);
endprogram
