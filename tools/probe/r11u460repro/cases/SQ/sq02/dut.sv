// § pkgTdForeignSpecParams460
package u;
  class item; endclass
  class S #(type REQ = item, type RSP = REQ);
    REQ r;
  endclass
  typedef S #(item, item) dflt_t;
endpackage
package a;
  import u::*;
  class a_item extends item; endclass
  typedef S #(a_item) a_seqr;
endpackage
package t;
  import u::*;
  import a::*;
  class env;
    a_seqr h;
  endclass
endpackage
module top;
  import u::*;
  import t::*;
  initial begin env e; e = new; end
endmodule
