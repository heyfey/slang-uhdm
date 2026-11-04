// § clsScopedOvRhsRefObj483
package p; class K; parameter w = 7; endclass endpackage
module leaf #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module mid (output logic [7:0] o); import p::*; leaf #(.A(K::w)) l(o); endmodule
module top; logic [7:0] o1, o2; mid a(o1); mid b(o2); endmodule
