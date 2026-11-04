// § clsOvDepParamOpTree485
class K; parameter w = 5; endclass
module m #(parameter A = 4, parameter W = 2) (output logic [7:0] o);
  localparam B = A + W;
  assign o = 8'd0;
endmodule
module top; logic [7:0] o; m #(.A(K::w), .W(3)) u(o); endmodule
