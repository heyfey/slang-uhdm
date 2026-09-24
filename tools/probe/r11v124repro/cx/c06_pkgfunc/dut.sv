// § castTsFile124
package p; function automatic logic [3:0] tr(logic [7:0] x); return 4'(x); endfunction endpackage
module top(input logic [7:0] a, output logic [3:0] o); assign o = p::tr(a); endmodule
