// § ovDefparamWinsValue485
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; for (genvar i = 0; i < 2; i++) begin : g logic [7:0] o; m #(.A(5)) u(o); end defparam g[0].u.A = 6; endmodule
