// § pkgTdForeignSpecParams460
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
module top;
  import u::*;
  import a::*;
  a_seqr h;
endmodule
