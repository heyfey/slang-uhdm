// § classImportParamOwnRefs183
package u;
  parameter int W = 8;
  localparam int D = 2;
  class base; endclass
endpackage
package s;
  import u::*;
  class d1 extends base; int x; endclass
endpackage
module top; endmodule
