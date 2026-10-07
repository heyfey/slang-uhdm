// § bindChildDisplayScopedNames283
interface ifc (input logic [3:0] d); logic [3:0] q; assign q = d; endinterface
module mon (input logic [3:0] d);
  logic [3:0] y [2];
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = d;
  end
endmodule
module dut (input logic [3:0] d, output logic [3:0] o);
  ifc u_i (.d(d));
  bind ifc mon u_m (.d(d));
  assign o = u_i.q;
endmodule
