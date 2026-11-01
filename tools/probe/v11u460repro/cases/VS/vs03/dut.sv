// § pkgTdForeignSpecParams460 (qualified u::S without an import)
package u;
  class item; endclass
  class S #(type REQ = item, type RSP = REQ);
    REQ r;
  endclass
endpackage
package a;
  class a_item extends u::item; endclass
  typedef u::S #(a_item) a_seqr;
endpackage
module top;
  import a::*;
  a_seqr h;
  initial h = new;
endmodule
