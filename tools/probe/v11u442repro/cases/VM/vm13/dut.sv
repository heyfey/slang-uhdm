// § modClassTdListing442
package p;
  class C #(int N = 1);
    int a;
  endclass
  typedef C#(2) pc_t;
endpackage
module top;
  import p::*;
  typedef C#(5) c_t;
  c_t h;
endmodule
