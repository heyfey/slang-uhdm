// § genChildParentAtBirth261
module leaf (input logic [31:0] d, output logic [15:0] o);
  logic [31:0] r;
  assign r = d;
  assign o = r[31:16];
endmodule
module mid (input logic [31:0] d, output logic [15:0] o, output logic [15:0] h);
  if (1) begin : g
    leaf l (.d(d), .o(o));
  end
  assign h = g.l.r[15:0];
endmodule
module top;
  logic [31:0] d; logic [15:0] o, h;
  mid m (.d(d), .o(o), .h(h));
endmodule
