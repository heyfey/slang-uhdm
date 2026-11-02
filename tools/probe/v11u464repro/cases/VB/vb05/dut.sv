// § unitClsListsSpecBase464 (the $unit class extends the base)
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
  typedef S #(a_item, 3) A_seqr;
endpackage
import u::*;
import a::*;
class test extends A_seqr;
  int k;
endclass
module top;
  initial begin test t; t = new; end
endmodule
