// § clsPropSpecTpFullName468
package q;
  class C #(type T = int);
    T m;
  endclass
  class env;
    C #(byte) comp;
  endclass
endpackage
module top; q::env e; endmodule
