// § clsShortRealAliasElem464 (a package alias)
package p;
  typedef shortreal sr_t;
endpackage
class C;
  p::sr_t d[];
endclass
module top;
  initial begin C c; c = new; end
endmodule
