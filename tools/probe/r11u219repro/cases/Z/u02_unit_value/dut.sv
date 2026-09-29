// § unitImportCopyValueFollowsPkg214 — untyped arithmetic package parameters hoisted by a $unit import (INT, not UINT)
package p;
  parameter LW = 120;
  parameter NL = 20;
  parameter LS = LW*NL*8-1;
  parameter SS = LW*8-1;
endpackage
import p::*;
module top(output int o);
  assign o = SS;
endmodule
