// § clsTdAssocIdxKwLoc251 (a PACKAGE-level associative typedef indexed by string, not a class typedef)
package p;
  typedef int tab_t [string];
  tab_t m;
endpackage
module top; import p::*; tab_t v; endmodule
