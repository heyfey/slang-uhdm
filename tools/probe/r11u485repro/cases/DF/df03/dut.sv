// § ovDefparamWinsValue485
package p; parameter W = 5; endpackage
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o; m #(.A(p::W)) u(o); defparam u.A = 6; endmodule
