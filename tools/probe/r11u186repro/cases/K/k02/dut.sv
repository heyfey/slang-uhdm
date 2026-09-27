// § classImportParamOwnRefs183 (a string and a bit-vector parameter)
package u;
  parameter string NAME = "abc";
  parameter bit [3:0] MASK = 4'h9;
  class base; endclass
endpackage
package s;
  import u::*;
  class d1 extends base; endclass
  class d2 extends base; int y; endclass
endpackage
module top; endmodule
