// § firstListerNamesClassTd463 (four packages d c b a)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
  class C; int k; endclass
endpackage
package d; import u::*; class d_item extends item; endclass typedef S #(d_item) d_seqr; endpackage
package c; import u::*; class c_item extends item; endclass typedef S #(c_item) c_seqr; endpackage
package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; endpackage
module top;
endmodule
