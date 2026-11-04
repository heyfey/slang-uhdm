// § specArgTypedefNameShares468
package q;
  class C #(type T = int, type U = int);
    T m;
  endclass
  class D;
    typedef D this_type;
    C #(int, this_type) x;
  endclass
endpackage
module top; q::D d; endmodule
