// § firstListerNamesClassTd463 (a module and an interface both use the group from imports)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
  class C; int k; endclass
endpackage
package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; endpackage
interface ifc; import a::*; a_seqr q; endinterface
module top; import b::*; import a::*; b_seqr x; a_seqr y; ifc i(); endmodule
