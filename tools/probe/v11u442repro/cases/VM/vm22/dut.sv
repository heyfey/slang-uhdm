// § modClassTdListing442
class C;
endclass
typedef C u_t;
module top;
  class C;
    int z;
  endclass
  typedef C c_t;
  c_t h;
  u_t k;
endmodule
