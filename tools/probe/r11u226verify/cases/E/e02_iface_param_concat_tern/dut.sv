// § pkgQualOperandSpanInParam218 — package-qualified operands in an interface parameter's concatenation and a conditional, and a module localparam
package cfg;
  localparam logic [3:0] K = 4'd9;
  localparam int SEL = 1;
endpackage
interface bus_i #(parameter logic [7:0] PK = {cfg::K, 4'h0},
                  parameter int PT = cfg::SEL ? cfg::K : 2) ();
  logic [7:0] d;
endinterface
module top(output int o);
  localparam int L = cfg::SEL + cfg::K;
  bus_i u_b();
  assign o = L + u_b.PT;
endmodule
