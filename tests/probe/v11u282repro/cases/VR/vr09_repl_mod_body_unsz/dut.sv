// § genCaReplCountUnsizedClone282
module top #(parameter int W = 2) (input logic [7:0] e, output logic [7:0] q);
  assign q = {W{e[3:0]}} | '0;
endmodule
