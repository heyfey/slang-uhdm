// § genChildParentAtBirth261
module leaf (input logic [31:0] d, output logic [15:0] o, output logic [3:0] p);
  assign o = d[31:16];
  assign p = d[3:0] ^ d[7:4];
endmodule
module mid #(parameter bit B = 1) (input logic [31:0] d, output logic [15:0] o, output logic [3:0] p);
  if (B)
    leaf l (.d(d), .o(o), .p(p));
endmodule
module top;
  logic [31:0] d; logic [15:0] o; logic [3:0] p;
  mid m (.d(d), .o(o), .p(p));
endmodule
