// § clsScopedOvRhsRefObj483
class K; parameter w = 2; endclass
module m #(parameter A = 1) (output logic [7:0] o);
  if (A > 1) begin : g assign o = 8'd1; end else begin : h assign o = 8'd2; end
endmodule
module top; logic [7:0] o; m #(.A(K::w)) u(o); endmodule
