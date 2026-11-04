// § unitClsListsSpecBase464 (a typedef of the base in the same package)
package u;
  class item; endclass
  class S #(type REQ = item, int N = 2);
    REQ r;
    logic [N-1:0] w;
  endclass
endpackage
package a;
  import u::*;
  class a_item extends item; endclass
  typedef S #(a_item) A_seqr;
  typedef A_seqr B_seqr;
endpackage
import u::*;
import a::*;
class test;
  B_seqr q;
endclass
module top;
  initial begin test t; t = new; end
endmodule
