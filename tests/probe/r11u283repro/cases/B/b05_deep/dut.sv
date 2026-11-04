// § bindChildDisplayScopedNames283
module tgt (input logic [3:0] d, output logic [3:0] o); assign o = d; endmodule
module mid (input logic [3:0] d, output logic [3:0] o); tgt u_t (.d(d), .o(o)); endmodule
module mon (input logic [3:0] d);
  logic [3:0] y;
  if (1) begin : g
    assign y = d;
  end
endmodule
module dut (input logic [3:0] d, output logic [3:0] o);
  mid u_mid (.d(d), .o(o));
  bind tgt mon u_m (.d(d));
endmodule
