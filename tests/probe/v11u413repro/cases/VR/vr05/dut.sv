// § stdRandomizeFuncCall413
module top;
  int a;
  bit [3:0] b;
  initial begin
    if (randomize(a, b) == 0) $display("fail");
  end
endmodule
