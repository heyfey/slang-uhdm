// § enumSubstDecDecompile411
module top (input logic [2:0] x, output logic o, output logic o2);
  typedef enum logic [2:0] { P = 3'd2, W, E = 3'b111 } d_t;
  assign o = (x == P);
  assign o2 = (x == E);
endmodule
