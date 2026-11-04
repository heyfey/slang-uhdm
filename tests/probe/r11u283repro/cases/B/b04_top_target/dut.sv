// § bindChildDisplayScopedNames283
module tgt (input logic [3:0] d, output logic [3:0] o); assign o = d; endmodule
module mon (input logic [3:0] d);
  logic [3:0] y;
  if (1) begin : g
    assign y = d;
  end
endmodule
bind tgt mon u_m (.d(d));
