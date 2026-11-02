// § firstListerNamesClassTd463 (the name-later typedef of the later package is the object the earlier package lists)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
endpackage
package b;
  import u::*;
  class b_item extends item; endclass
  typedef S #(b_item) a_seqr;
endpackage
package a;
  import u::*;
  class a_item extends item; endclass
  typedef S #(a_item) z_seqr;
endpackage
module top;
endmodule
