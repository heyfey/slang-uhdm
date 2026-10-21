// § unszBasedPkgFoldUnsized423
package p;
  parameter R = 'hf000000;
endpackage
import p::*;
class C;
  function int f(int x);
    return x & R;
  endfunction
endclass
module top; C c; endmodule
