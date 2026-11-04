// § clsImpParamOncePerName452
package u;
  parameter int P1 = 1;
endpackage
package e1;
  import u::*;
endpackage
package tp;
  import u::*;
  import e1::*;
  class C;
    int x;
  endclass
endpackage
module top;
  import tp::*;
endmodule
