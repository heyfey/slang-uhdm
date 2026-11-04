// § unitClsListsSpecBase464 (two $unit classes: the last by name writes)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
endpackage
package a;
  import u::*;
  class a_item extends item; endclass
  typedef S #(a_item) A_seqr;
endpackage
import u::*;
import a::*;
class zz;
  A_seqr q;
endclass
class aa;
  A_seqr q;
endclass
module top;
  initial begin zz t; aa w; t = new; w = new; end
endmodule
