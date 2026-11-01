// § pkgTdForeignSpecParams460 (two packages specializing the same class)
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
  import u::*;
  class b_item extends item; endclass
  typedef S #(b_item, item) b_seqr;
endpackage
module top;
  import a::*;
  import b::*;
  a_seqr x; b_seqr y;
  initial begin x = new; y = new; end
endmodule
