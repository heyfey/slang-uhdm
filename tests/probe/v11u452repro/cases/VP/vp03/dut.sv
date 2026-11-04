// § clsImpParamOncePerName452
package u;
  parameter int P1 = 1;
endpackage
package a;
  import u::*;
  parameter int P1A = 4;
endpackage
package e1;
  import u::*;
  import a::*;
  class C;
    int x;
  endclass
endpackage
module top;
  import e1::*;
endmodule
