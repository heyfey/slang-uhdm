// § genCaStructParamSharesPaOperand287
package p; typedef struct packed { int unsigned n; logic [7:0] d; logic signed [7:0] s; } cfg_t; localparam cfg_t LIT = '{n: 300, d: 8'd6, s: 8'sd3}; endpackage
module dut #(parameter p::cfg_t CFG = p::LIT, parameter int K = 1) (output logic [7:0] o);
  case (K) 1: begin : g assign o[7:0] = CFG.d; end default: begin : h assign o = 0; end endcase
endmodule
