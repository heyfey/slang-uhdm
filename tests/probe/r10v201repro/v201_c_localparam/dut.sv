// v201 arm C — LOCALPARAMS, literal- and reference-defaulted, imported.
package p201vc;
  localparam C_LA = 13;
  localparam C_LB = C_LA;
  parameter  C_PA = 21;
  localparam C_LC = C_PA;
  parameter  C_PB = C_LA;
endpackage
import p201vc::*;
module m201vc;
endmodule
