// § firstListerNamesClassTd463 (a $unit typedef of an unrelated generic class beside the group)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
  class C; int k; endclass
endpackage
package u3; class T #(type X = int); X x; endclass endpackage
import u3::*;
typedef T #(int) aa_other;
package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; endpackage
module top;
endmodule
