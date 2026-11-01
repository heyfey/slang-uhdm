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
  class env;
    a_seqr h;
  endclass
endpackage
module top;
  initial begin a::env e; e = new; end
endmodule
