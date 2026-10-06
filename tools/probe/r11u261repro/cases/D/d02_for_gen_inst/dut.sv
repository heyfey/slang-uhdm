// § genChildParentAtBirth261
module leaf (input logic [31:0] d, input logic [1:0] s, output logic [15:0] o, output logic b);
  assign o = d[31:16];
  assign b = d[s];
endmodule
module mid (input logic [31:0] d, output logic [15:0] o [2], output logic b [2]);
  for (genvar i = 0; i < 2; i++) begin : g_arr
    leaf l (.d(d), .s(2'(i)), .o(o[i]), .b(b[i]));
  end
endmodule
module top;
  logic [31:0] d; logic [15:0] o [2]; logic b [2];
  mid m (.d(d), .o(o), .b(b));
endmodule
