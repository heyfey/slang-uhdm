// § specGroupAliasFlatRoot460 (two typedefs of the generic class in its home package)
package u;
  class item; endclass
  class S #(type REQ = item, type RSP = REQ);
    REQ r;
  endclass
  typedef S #(item, item) dflt_t;
  typedef S #(item) virt_t;
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
    a_seqr h; virt_t v; dflt_t d;
  endclass
endpackage
module top;
  import u::*;
  import t::*;
  initial begin env e; e = new; end
endmodule
