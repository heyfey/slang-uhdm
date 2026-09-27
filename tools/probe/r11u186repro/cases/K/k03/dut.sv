// § classImportParamOwnRefs183 (a module importer beside the package importer)
package u;
  parameter int W = 8;
  class base; endclass
endpackage
package s;
  import u::*;
  class d1 extends base; endclass
endpackage
module top;
  import u::*;
  int v = W;
endmodule
