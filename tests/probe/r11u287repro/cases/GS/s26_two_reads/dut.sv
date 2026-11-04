// § genCaStructParamSharesPaOperand287
package p; typedef struct packed { int unsigned n; int unsigned m; } cfg_t; localparam cfg_t LIT = '{n: 3, m: 7}; endpackage
module dut #(parameter p::cfg_t CFG = p::LIT) (output logic [31:0] o, o2);
  if (1) begin : g assign o[0] = CFG.n; assign o2[1] = CFG.n; end
endmodule
