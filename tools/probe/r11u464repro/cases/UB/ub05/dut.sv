// § unitClsListsSpecBase464 (no $unit class: the module stays the writer)
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
module top;
  initial begin A_seqr s; s = new; end
endmodule
