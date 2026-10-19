// § foreachUnitImportElemVar403
package p;
int q[$];
function int f();
  int s = 0;
  foreach (q[i]) s += q[i];
  return s;
endfunction
endpackage
import p::*;
module top; endmodule
