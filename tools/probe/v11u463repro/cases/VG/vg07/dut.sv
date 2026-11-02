// § firstListerNamesClassTd463 (a class-nested typedef of the generic class in the later-declared package)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
  class C; int k; endclass
endpackage
package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass
  class K; typedef S #(a_item) a_seqr; a_seqr h; endclass
  typedef S #(a_item) a_top;
endpackage
module top;
endmodule
