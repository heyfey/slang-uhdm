// § dynArrNewElemLvalueBase437
package p;
function automatic void f(); int d[2][]; d[0] = new[5]; endfunction
endpackage
module top; initial p::f(); endmodule
