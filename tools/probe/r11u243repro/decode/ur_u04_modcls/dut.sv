// § clsImpUnsizedBasedRhsCopy243
// a module-scope import of an unsized based parameter and a $unit class read in the module
package q;
  parameter R = 'h1f;
  parameter W = 'd3;
endpackage
import q::*;
class c;
  function int f(); return R; endfunction
endclass
module top;
  import q::*;
  c h;
  int x;
  initial x = R;
endmodule
