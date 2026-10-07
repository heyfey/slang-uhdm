// § clsTdScopedTargetQualSpan279
`include "inc.svh"
package pb;
  class ub;
    typedef rp::regb #(2) tidb;
  endclass
  class ub2;
    typedef rp::regb #(3) tidb;
  endclass
endpackage
module top; pb::ub v; pb::ub2 w; initial begin v = null; w = null; end endmodule
