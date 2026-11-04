// § genCaStructParamSharesPaOperand287
package p; typedef struct packed { int unsigned n; int unsigned m; } cfg_t; localparam cfg_t LIT = '{n: 3, m: 7}; endpackage
module dut #(parameter p::cfg_t CFG = p::LIT) (output logic [31:0] o);
  if (1) begin : g wire [31:0] wv; assign wv = CFG.n; assign o = wv; end
endmodule
