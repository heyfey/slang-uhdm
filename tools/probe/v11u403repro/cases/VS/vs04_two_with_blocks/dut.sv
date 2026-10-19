// § stdRandomizeIsScopeRef403
module top;
  int x, y, s;
  initial begin
    s = std::randomize(x) with { x < 4; };
    s = std::randomize(y) with { y > 2; };
  end
endmodule
