// § stdRandomizeFuncCall413
module top;
  int a;
  bit ok;
  initial begin
    ok = std::randomize(a);
  end
endmodule
