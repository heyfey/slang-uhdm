// § clsScopedOvRhsRefObj483
class K; parameter w = 3; endclass
module m #(parameter A = 4) (output logic [7:0] o); assign o = A; endmodule
module top; logic [7:0] o [2];
  for (genvar i = 0; i < 2; i++) begin : g
    if (i == 0) begin : t m #(.A(K::w)) u(o[i]); end
    else begin : e m #(.A(5)) u(o[i]); end
  end
endmodule
