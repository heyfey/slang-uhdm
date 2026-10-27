// § modClassTdListing442
class C;
endclass
class D;
endclass
module top;
  typedef D d_t;
  typedef C c_t;
  c_t h;
  d_t g;
endmodule
module abc;
  typedef C e_t;
  e_t k;
endmodule
