// § importVarElemOwnName214 — the array declared before the only class
package p;
  int plain_arr [4];
  class cc; int s; endclass
endpackage
module top; import p::*; endmodule
