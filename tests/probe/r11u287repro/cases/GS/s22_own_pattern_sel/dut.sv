// § genCaStructParamSharesPaOperand287
package p; typedef struct packed { int unsigned n; int unsigned m; } cfg_t; endpackage
module dut #(parameter p::cfg_t CFG = '{n: 3, m: 7}) (output logic [31:0] o);
  if (1) begin : g assign o[0] = CFG.n; end
endmodule
