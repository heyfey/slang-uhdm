// § genCaStructParamSharesPaOperand287
package p; typedef struct packed { int unsigned n; int unsigned m; } cfg_t; localparam cfg_t LIT = '{n: 3, m: 7}; endpackage
interface ifc #(parameter p::cfg_t C = p::LIT) ();
  logic [31:0] w;
  if (1) begin : g assign w[0] = C.n; end
endinterface
module dut (output logic [31:0] o); ifc u (); assign o = u.w; endmodule
