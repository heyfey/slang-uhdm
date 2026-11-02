// § firstListerNamesClassTd463
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
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
package c;
  import u::*;
  class c_item extends item; endclass
  typedef S #(c_item) c_seqr;
endpackage
module top;
endmodule
