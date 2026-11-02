// § firstListerNamesClassTd463 (two generic classes, interleaved groups)
package u; class item; endclass
  class S #(type REQ = item); REQ r; endclass
  class D #(type REQ = item); REQ r; endclass
endpackage
package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; typedef D #(b_item) b_drv; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; typedef D #(a_item) a_drv; endpackage
module top;
endmodule
