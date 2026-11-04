// § unitClsListsSpecBase464
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
class test;
  A_seqr q;
endclass
module top;
  initial begin test t; t = new; end
endmodule
