// § unitGroupAbstain463v (a $unit typedef of the same generic class after the packages; the law renamed a::a_seqr where golden keeps it)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
  class C; int k; endclass
endpackage
package b; import u::*; class b_item extends item; endclass typedef S #(b_item) b_seqr; endpackage
package a; import u::*; class a_item extends item; endclass typedef S #(a_item) a_seqr; endpackage
import u::*;
class ui extends item; endclass
typedef S #(ui) zz_unit_seqr;
module top;
endmodule
