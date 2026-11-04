// § clsOvExprActualOpTree485
class K; parameter w = 5; endclass
module m #(parameter int A = 4) (output logic [7:0] o);
  assign o = 8'd0;
endmodule
module top; logic [7:0] o; m #(.A(K::w + 1)) u(o); endmodule
