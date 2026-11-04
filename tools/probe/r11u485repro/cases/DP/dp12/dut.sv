// § clsOvDepParamOpTree485
class K; parameter w = 5; endclass
module m #(parameter A = 4) (output logic [7:0] o);
  localparam B = A + 1;
  assign o = 8'd0;
endmodule
module top; logic [7:0] o, o2; m #(.A(K::w)) u(o); m v(o2); endmodule
