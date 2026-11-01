// § clsNestedSpecCloneHomeInst460 (two packages specialize a class holding this_type)
package u;
  class item; endclass
  class S #(type REQ = item);
    typedef S #(REQ) this_type;
    REQ r;
  endclass
endpackage
package a;
  import u::*;
  class a_item extends item; endclass
  typedef S #(a_item) a_seqr;
endpackage
package b;
  import u::*;
  class b_item extends item; endclass
  typedef S #(b_item) b_seqr;
endpackage
package t;
  import u::*;
  import a::*;
  import b::*;
  class env;
    a_seqr x; b_seqr y;
  endclass
endpackage
module top;
  import t::*;
  env h;
  initial h = new;
endmodule
