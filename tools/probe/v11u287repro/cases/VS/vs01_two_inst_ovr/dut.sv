// § genCaStructParamSharesPaOperand287
package p; typedef struct packed { int unsigned n; logic [7:0] d; logic signed [7:0] s; } cfg_t; localparam cfg_t LIT = '{n: 300, d: 8'd6, s: 8'sd3}; endpackage
module c #(parameter p::cfg_t CFG = p::LIT) (output logic [31:0] o);
  if (1) begin : g assign o[7:0] = CFG.d; end
endmodule
module dut(output logic [31:0] o1, o2);
  c u1(.o(o1));
  c #(.CFG('{n: 1, d: 8'd9, s: 8'sd1})) u2(.o(o2));
endmodule
