// § importFnListUsedOnly412
package p2;
function int f(); return 1; endfunction
function int g(); return 2; endfunction
endpackage
module top;
import p2::*;
int x;
initial x = 1;
endmodule
