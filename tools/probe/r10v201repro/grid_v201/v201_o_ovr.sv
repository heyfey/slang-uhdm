// v201 arm O — the importer OVERRIDES its own parameter, and a chain of
// three reference-defaulted copies.
package p201vo;
  parameter O_A = 13;
  parameter O_B = O_A;
  parameter O_C = O_B;
endpackage
import p201vo::*;
module leaf201vo #(parameter LP = 4);
  import p201vo::*;
endmodule
module m201vo;
  leaf201vo #(.LP(7)) u();
endmodule
