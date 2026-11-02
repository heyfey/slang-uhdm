// § firstListerNamesClassTd463 (a module-local typedef of the same generic class beside package typedefs)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
  class C; int k; endclass
endpackage
package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; endpackage
module top;
  import u::*;
  typedef S #(item) aa_mod_seqr;
  aa_mod_seqr h;
endmodule
