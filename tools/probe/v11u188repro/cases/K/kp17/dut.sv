// § tpOwnTsAtHeaderDefault188
package p;
  typedef int myint;
  class c #(type T = int);
    T p;
  endclass
  // c #(myint) h1;
  // c #(.T(int)) h2;
endpackage
module top;
  p::c #(int) h1;
  p::c h2;
endmodule
