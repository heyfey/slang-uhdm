// § unitClsListsSpecBase464 (two $unit classes listing the base)
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
  typedef S #(a_item, 4) A_seqr;
endpackage
import u::*;
import a::*;
class test1;
  A_seqr q;
endclass
class test2;
  A_seqr q;
endclass
module top;
  initial begin test1 t; test2 t2; t = new; t2 = new; end
endmodule
