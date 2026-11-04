// § uninstProgSubBodyAsUninstIface439
program prg;
int x, y;
function automatic int f(int a); return a + y; endfunction
task automatic t(int b); x = f(b); endtask
initial begin t(x); y = f(x); end
endprogram
