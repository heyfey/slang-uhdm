// § importVarElemOwnName214 — a package int array between two classes (which class names the element?)
package p;
  class zz_c; int s; endclass
  int plain_arr [4];
  class aa_c; int t; endclass
endpackage
module top; import p::*; endmodule
