// § firstListerNamesClassTd463 (control: the declaring package is the first lister)
package u;
  class item; endclass
  class S #(type REQ = item);
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
  typedef S #(b_item) b_seqr;
endpackage
module top;
endmodule
