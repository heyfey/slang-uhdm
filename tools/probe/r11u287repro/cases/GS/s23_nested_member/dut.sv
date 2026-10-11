// § genCaStructParamSharesPaOperand287
package p; typedef struct packed { int unsigned a; } in_t; typedef struct packed { in_t s; int unsigned m; } cfg_t;
  localparam cfg_t LIT = '{s: '{a: 5}, m: 7}; endpackage
module dut #(parameter p::cfg_t CFG = p::LIT) (output logic [31:0] o);
  if (1) begin : g assign o[0] = CFG.s.a; end
endmodule
