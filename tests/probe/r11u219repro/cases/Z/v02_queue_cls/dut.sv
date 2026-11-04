// § importVarElemOwnName214 — an associative array of a class keyed by int, inherited by two classes of an importing package
package p;
  class item_c; int s; endclass
  item_c tbl [int];
endpackage
package q;
  import p::*;
  class a_c; int y; endclass
  class b_c; int z; endclass
endpackage
