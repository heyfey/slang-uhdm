// § modClassTdListing442
class C;
endclass
module aa;
  class C;
    int z;
  endclass
  typedef C d_t;
  d_t g;
endmodule
module top;
  typedef C c_t;
  c_t h;
  aa u();
endmodule
