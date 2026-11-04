// § genChildParentAtBirth261
module leaf (input logic [31:0] d, output logic [15:0] o, output logic [3:0] p);
  assign o = d[31:16];
  assign p = d[3:0] ^ d[7:4];
endmodule
module mid (input logic [31:0] d, output logic [15:0] o, output logic [3:0] p);
  if (1) begin : g1
    leaf l (.d(d), .o(o), .p(p));
  end
endmodule
module upper (input logic [31:0] d, output logic [15:0] o, output logic [3:0] p);
  for (genvar i = 0; i < 1; i++) begin : g0
    mid m (.d(d), .o(o), .p(p));
  end
endmodule
module top;
  logic [31:0] d; logic [15:0] o; logic [3:0] p;
  upper u (.d(d), .o(o), .p(p));
endmodule
