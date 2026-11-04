// § unitClsListsSpecBase464 (the base in the same package as the generic class)
package u;
  class item; endclass
  class S #(type REQ = item);
    REQ r;
  endclass
  typedef S #(item) I_seqr;
endpackage
import u::*;
class test;
  I_seqr q;
endclass
module top;
  initial begin test t; t = new; end
endmodule
