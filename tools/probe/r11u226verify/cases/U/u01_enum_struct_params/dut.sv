// § unitImportCopyOwnTsRef214 § unitImportCopyValueFollowsPkg214 — a $unit wildcard import of an enum-typed parameter, a byte parameter, an untyped expression of two parameters and a localparam
package p;
  typedef enum logic [1:0] {L0, L1, L2} lvl_e;
  parameter lvl_e LV = L2;
  parameter byte BY = 8'sd100;
  parameter X = BY*2 - 7;
  localparam int unsigned U = 32'd40000;
endpackage
import p::*;
module top(output int o);
  assign o = int'(LV) + BY + X + U;
endmodule
