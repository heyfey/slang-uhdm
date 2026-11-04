// § importCopyTsInstByRole469
// untyped, int and ranged parameters: the param_assign role's one-hop typespec
package a;
  parameter PA = 1;
  parameter int PI = 2;
  parameter logic [3:0] PL = 3;
endpackage
package b;
  import a::*;
endpackage
module top;
  logic w;
endmodule
