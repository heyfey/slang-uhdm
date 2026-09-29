// § importVarElemOwnName214 — a dynamic array of a class inherited by a class of an importing package
package p;
  class item_c; int s; endclass
  item_c pool [];
endpackage
package q;
  import p::*;
  class user_c;
    int y;
  endclass
endpackage
