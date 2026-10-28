// § clsImpParamOncePerName452
package u;
  parameter int P1 = 1;
  localparam int L1 = 3;
endpackage
package a;
  import u::*;
endpackage
package b;
  import u::*;
endpackage
package e1;
  import a::*;
  import b::*;
  import u::*;
endpackage
package tp;
  import e1::*;
  class C;
    int x;
  endclass
endpackage
module top;
  import tp::*;
endmodule
