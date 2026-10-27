// § modClassTdListing442
package p;
  class C;
  endclass
  typedef C pc_t;
endpackage
module top;
  typedef p::C c_t;
  c_t h;
  p::pc_t g;
endmodule
