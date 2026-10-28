// § clsImpParamOncePerName452
package u;
  parameter int P = 1;
endpackage
package v;
  parameter int P = 2;
endpackage
package e1;
  import u::*;
  import v::*;
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
