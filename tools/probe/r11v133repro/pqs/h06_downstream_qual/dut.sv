// § elabPatQualRefQualSpan133
package cfg_pkg;
  typedef struct packed { logic [7:0] W; logic E; } cfg_t;
  localparam cfg_t Cfg = '{W: 8'd5, E: 1'b1};
endpackage
module dut import cfg_pkg::*; #(parameter cfg_t Cfg = cfg_pkg::Cfg) (input logic clk, input logic [7:0] a, output logic [7:0] o);
  always_ff @(posedge clk) o <= Cfg.E ? a + Cfg.W : a;
endmodule
