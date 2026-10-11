// § genCaStructParamSharesPaOperand287
package p; typedef struct packed { int unsigned n; logic [7:0] d; logic signed [7:0] s; } cfg_t; localparam cfg_t LIT = '{n: 300, d: 8'd6, s: 8'sd3}; endpackage
module dut (output logic [7:0] o);
  localparam p::cfg_t CFG = '{n: 2, d: 8'd5, s: 8'sd0};
  if (1) begin : g assign o[7:0] = CFG.d; end
endmodule
