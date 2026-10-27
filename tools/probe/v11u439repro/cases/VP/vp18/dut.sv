// § uninstProgBodyAsUninstIface439
int gv;
parameter int GP = 7;
function automatic int gf(int a); return a + GP; endfunction
package pk;
function automatic int pf(int a); return a * 2; endfunction
endpackage
program prg;
int x;
initial begin x = gv; x = GP; x = gf(1); x = pk::pf(2); end
endprogram
