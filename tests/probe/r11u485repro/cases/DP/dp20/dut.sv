// § clsOvDepParamOpTree485
class K; parameter w = 5; endclass
module m #(parameter A = 4) (output logic [7:0] o);
  localparam B = A ? 1 : 2;
  assign o = 8'd0;
endmodule
module top; logic [7:0] o; m #(.A(K::w)) u(o); endmodule
