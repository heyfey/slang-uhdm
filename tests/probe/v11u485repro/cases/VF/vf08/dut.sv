// § ovDefparamWinsValue485
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o; if (1) begin : g m #(.A(5)) u(o); end defparam g.u.A = 6; endmodule
