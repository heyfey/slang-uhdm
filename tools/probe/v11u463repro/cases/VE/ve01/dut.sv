// § firstListerNamesClassTd463 (explicit import and export of a class typedef, later package)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
  class C; int k; endclass
endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; endpackage
package b; import a::a_seqr; export a::a_seqr; endpackage
module top; import b::*; a_seqr x; initial x = new; endmodule
