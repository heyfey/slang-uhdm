// § firstListerNamesClassTd463 (an earlier package lists a late-named typedef of the same class first)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
  class C; int k; endclass
endpackage
package u2;
  import u::*;
  typedef S #(item) z_dflt;
endpackage
package b;
  import u::*;
  class b_item extends item; endclass
  typedef S #(b_item) b_seqr;
endpackage
package a;
  import u::*;
  class a_item extends item; endclass
  typedef S #(a_item) a_seqr;
endpackage
module top;
endmodule
