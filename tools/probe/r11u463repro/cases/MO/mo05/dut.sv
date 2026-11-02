// § firstListerNamesClassTd463
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
  typedef S #(item) dflt_t;
endpackage
package b;
  import u::*;
  class b_item extends item; endclass
  typedef S #(b_item) b_seqr;
endpackage
package a;
  import u::*;
  class a_item extends item; endclass
  typedef S #(a_item) a_seqr;
endpackage
module top;
endmodule
