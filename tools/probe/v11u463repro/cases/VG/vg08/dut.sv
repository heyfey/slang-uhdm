// § firstListerNamesClassTd463 (module and class variables typed by the renamed typedef, through import)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
  class C; int k; endclass
endpackage
package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr;
  class env; a_seqr s; b::b_seqr t; endclass
endpackage
module top;
  import a::*;
  a_seqr m;
  env e;
  initial begin m = new; e = new; end
endmodule
