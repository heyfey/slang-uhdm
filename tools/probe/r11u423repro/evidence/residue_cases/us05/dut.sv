// residue (no law landed): see README
package p;
  parameter R = 'd12;
  parameter S = 'b101;
endpackage
import p::*;
class C;
  function int f(int x);
    return (x & R) | S;
  endfunction
endclass
module top; C c; endmodule
