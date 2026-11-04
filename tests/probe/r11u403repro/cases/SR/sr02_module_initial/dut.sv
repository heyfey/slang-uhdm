// § stdRandomizeIsScopeRef403
module top;
  int x, z, s;
  initial begin
    s = std::randomize(x);
    s = std::randomize(x, z);
    s = std::randomize(x) with {x > 3;};
  end
endmodule
