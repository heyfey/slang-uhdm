// § firstListerNamesClassTd463 (wildcard import and export of a class typedef, later package also specializes)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
  class C; int k; endclass
endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; endpackage
package b; import u::*; import a::*; export a::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; a_seqr h; endpackage
module top; import b::*; a_seqr x; initial x = new; endmodule
