// § firstListerNamesClassTd463 (a later package names an earlier package's typedef by scope)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
  class C; int k; endclass
endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) z_seqr; endpackage
package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; a::z_seqr h; endpackage
module top;
endmodule
