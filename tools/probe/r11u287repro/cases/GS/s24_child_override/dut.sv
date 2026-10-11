// § genCaStructParamSharesPaOperand287
package p; typedef struct packed { int unsigned n; int unsigned m; } cfg_t; localparam cfg_t LIT = '{n: 3, m: 7}; endpackage
module leaf #(parameter p::cfg_t CFG = p::LIT) (output logic [31:0] o);
  if (1) begin : g assign o[3:0] = CFG.n; end
endmodule
module dut (output logic [31:0] o1, o2);
  leaf u1 (.o(o1));
  leaf #(.CFG('{n: 9, m: 1})) u2 (.o(o2));
endmodule
