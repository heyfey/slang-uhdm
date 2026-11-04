// § clsImpParamOncePerName452
package u;
  parameter int P1 = 1;
  parameter int P2 = 2;
endpackage
package a;
  import u::*;
endpackage
package e1;
  import u::*;
  import a::*;
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
