// § foreachUnitImportElemVar403
package p;
class W; int x; endclass
W qc[$];
W dc[];
W fc[2];
function void f();
  foreach (qc[i1]) qc[i1].x = 1;
  foreach (dc[i2]) dc[i2].x = 2;
  foreach (fc[i3]) fc[i3].x = 3;
endfunction
endpackage
package p2; import p::*; int z; endpackage
module top; endmodule
