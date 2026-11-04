// § implicitArgDimsInner155
package p; function automatic logic f([2:0] x); return x[0]; endfunction endpackage
module top(output logic o); assign o = p::f(3); endmodule
