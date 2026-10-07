// § bindChildDisplayScopedNames283
module tgt (input logic [3:0] d, output logic [3:0] o); assign o = d; endmodule
module leaf (input logic [3:0] d);
  logic [3:0] z;
  if (1) begin : lg
    assign z = d;
  end
endmodule
module mon (input logic [3:0] d);
  leaf u_l (.d(d));
  if (1) begin : g
    logic [3:0] y;
    assign y = d;
  end
endmodule
module dut (input logic [3:0] d, output logic [3:0] o);
  tgt u_t (.d(d), .o(o));
  bind tgt mon u_m (.d(d));
endmodule
