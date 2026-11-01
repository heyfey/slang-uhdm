// § pkgTdForeignSpecParams460 (alias chain across packages)
package u;
  class item; endclass
  class S #(type REQ = item, type RSP = REQ);
    REQ r;
  endclass
endpackage
package a;
  import u::*;
  class a_item extends item; endclass
  typedef S #(a_item) a_seqr;
endpackage
package b;
  import a::*;
  typedef a_seqr b_seqr;
endpackage
package c;
  import b::*;
  typedef b_seqr c_seqr;
endpackage
module top;
  import c::*;
  c_seqr h;
  initial h = new;
endmodule
