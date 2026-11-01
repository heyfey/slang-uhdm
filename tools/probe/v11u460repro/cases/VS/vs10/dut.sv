// § pkgTdForeignSpecParams460 (explicit import u::S)
package u;
  class item; endclass
  class S #(type REQ = item, type RSP = REQ);
    REQ r;
  endclass
endpackage
package a;
  import u::S;
  import u::item;
  class a_item extends item; endclass
  typedef S #(a_item) a_seqr;
endpackage
module top;
  import a::*;
  a_seqr h;
  initial h = new;
endmodule
