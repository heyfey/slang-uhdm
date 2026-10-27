// § uninstProgBodyAsUninstIface439
package pk;
int pv;
endpackage
program prg;
import pk::*;
int x;
initial begin x = pv; pk::pv = 2; end
endprogram
