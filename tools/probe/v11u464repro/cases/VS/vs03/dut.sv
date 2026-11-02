// § clsShortRealAliasElem464 (a package shortreal alias used by scope)
package p;
  typedef shortreal sr_t;
endpackage
class C;
  p::sr_t d[];
endclass
module top;
  initial begin C c; c = new; end
endmodule
