// § genChildParentAtBirth261
module leaf (input logic [31:0] d, output logic [15:0] o, output logic [3:0] p);
  assign o = d[31:16];
  assign p = d[3:0] ^ d[7:4];
endmodule
module mid (input logic [31:0] d, output logic [15:0] o [2], output logic [3:0] p [2]);
  if (1) begin : g
    leaf l [1:0] (.d(d), .o(o), .p(p));
  end
endmodule
module top;
  logic [31:0] d; logic [15:0] o [2]; logic [3:0] p [2];
  mid m (.d(d), .o(o), .p(p));
endmodule
