// § genCaStructParamSharesPaOperand287
package p; typedef struct packed { int unsigned n; logic [7:0] d; logic signed [7:0] s; } cfg_t; localparam cfg_t LIT = '{n: 300, d: 8'd6, s: 8'sd3}; endpackage
module dut #(parameter p::cfg_t CFG = p::LIT) (output logic [7:0] o [3], output logic [7:0] q);
  for (genvar i = 0; i < 3; i++) begin : g assign o[i] = CFG.d; end
  assign q = CFG.d;
endmodule
