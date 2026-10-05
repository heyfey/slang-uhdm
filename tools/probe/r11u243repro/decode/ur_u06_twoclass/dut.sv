// § clsImpUnsizedBasedRhsCopy243
// two $unit classes, one extending the other, under a $unit import
package q;
  parameter R = 'hf000000;
endpackage
import q::*;
class b;
  int v;
endclass
class d extends b;
  function int f(); return R; endfunction
endclass
module top;
  d h;
endmodule
