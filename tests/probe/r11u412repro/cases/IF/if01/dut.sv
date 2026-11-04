// § importFnListUsedOnly412
package p;
function int f(); return 1; endfunction
endpackage
package p2;
function int f(); return 1; endfunction
function int g(); return 2; endfunction
endpackage
module top;
import p::*;
int x;
initial x = f();
import p2::*;
endmodule
