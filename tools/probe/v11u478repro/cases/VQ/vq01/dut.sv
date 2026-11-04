// § aliasCopyParamUnnamed478 (a module typedef chain of a value specialization)
class C #(int W = 1, int V = 2);
  int x;
endclass
module top;
  typedef C #(4, 5) c_t;
  typedef c_t c2_t;
  c2_t h;
endmodule
