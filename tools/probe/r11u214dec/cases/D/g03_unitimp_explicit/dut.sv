// § unitImportCopyOwnTsRef214 — an explicit $unit import of one parameter (only the named item is hoisted)
package p;
  parameter W = 120;
  parameter L = W*8-1;
endpackage
import p::L;
module top(output int o);
  assign o = 0;
endmodule
