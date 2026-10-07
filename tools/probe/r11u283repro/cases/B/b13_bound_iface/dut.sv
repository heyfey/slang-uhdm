// § bindChildDisplayScopedNames283
interface mif (input logic [3:0] d);
  logic [3:0] y;
  if (1) begin : g
    assign y = d;
  end
endinterface
module tgt (input logic [3:0] d, output logic [3:0] o); assign o = d; endmodule
module dut (input logic [3:0] d, output logic [3:0] o);
  tgt u_t (.d(d), .o(o));
  bind tgt mif u_i (.d(d));
endmodule
