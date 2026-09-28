// (r11u191 split real port) real and realtime redeclarations of data-typeless outputs
module dut(a, d, t);
  input [3:0] a;
  output d;
  output t;
  real d;
  realtime t;
  always @(*) begin
    d = a;
    t = a;
  end
endmodule
