// § unitClsListsSpecBase464 (a base specialized twice in two packages)
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
package b;
  import u::*;
  import a::*;
  typedef S #(a_item) B_seqr;
endpackage
import u::*;
import a::*;
import b::*;
class test;
  A_seqr q;
  B_seqr r;
endclass
module top;
  initial begin test t; t = new; end
endmodule
