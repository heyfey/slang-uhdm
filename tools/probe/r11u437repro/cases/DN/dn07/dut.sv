// § dynArrNewElemLvalueBase437
package p;
function automatic void f(); int d[2][]; d[1] = new[2]; endfunction
endpackage
module top; initial p::f(); endmodule
