// § modClassTdListing442
class C;
endclass
module top;
  typedef C c_t;
  c_t h;
endmodule
typedef C u_t;
module m2;
  u_t g;
endmodule
