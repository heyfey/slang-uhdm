// § tdChainAbstain463v (a typedef of a typedef in the declaring package; the law renamed a::a2_seqr where golden keeps it)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
  class C; int k; endclass
endpackage
package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; typedef a_seqr a2_seqr; endpackage
module top;
endmodule
