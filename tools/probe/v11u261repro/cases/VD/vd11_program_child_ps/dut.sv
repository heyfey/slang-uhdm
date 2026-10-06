// § genChildParentAtBirth261
program prg (input logic [31:0] d, output logic [15:0] o);
  assign o = d[31:16];
endprogram
module mid (input logic [31:0] d, output logic [15:0] o);
  for (genvar i = 0; i < 1; i++) begin : g
    prg p (.d(d), .o(o));
  end
endmodule
module top;
  logic [31:0] d; logic [15:0] o;
  mid m (.d(d), .o(o));
endmodule
