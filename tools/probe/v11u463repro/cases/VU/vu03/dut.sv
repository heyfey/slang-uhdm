// § firstListerNamesClassTd463 (a function return typed by the renamed typedef)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
  class C; int k; endclass
endpackage
package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr;
  function automatic a_seqr mk(); mk = new; endfunction
endpackage
module top; import a::*; a_seqr y; initial y = mk(); endmodule
