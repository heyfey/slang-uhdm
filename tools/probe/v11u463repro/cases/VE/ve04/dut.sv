// § firstListerNamesClassTd463 (a parameter type defaulting to another package's class typedef)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
  class C; int k; endclass
endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; endpackage
package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; parameter type PT = a::a_seqr; endpackage
module top; b::PT x; initial x = new; endmodule
