// § classVarInitSpan152
class C #(type T=int);
  T x;
endclass
package pk;
  C#(longint) c1 = new;
endpackage
module top ();
  import pk::*;
endmodule
