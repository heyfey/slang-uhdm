// § stdRandomizeFuncCall413
module top;
  int a, b;
  initial begin
    if (std::randomize(a, b)) $display(a);
  end
endmodule
