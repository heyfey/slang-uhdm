// § unitClsListsSpecBase464 (the module also uses the base)
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
endpackage
import u::*;
import a::*;
class test;
  A_seqr q;
endclass
module top;
  A_seqr m;
  initial begin test t; t = new; m = new; end
endmodule
