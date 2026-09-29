// § unitImportCopyOwnTsRef214 — a $unit wildcard import of typed and untyped package parameters, read by a module
package p;
  parameter int A = 3;
  parameter B = A*4+1;
  localparam logic [3:0] C = 4'd9;
endpackage
import p::*;
module top(output int o);
  assign o = A + B + C;
endmodule
