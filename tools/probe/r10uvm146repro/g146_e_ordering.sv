// r10uvm146 arm E — the same package imported at $unit THREE times with a
// different package in between, and a fourth package whose only parameter is a
// TYPE parameter.  Varies multiplicity, interleaving and case from arm D so the
// grid cannot confirm itself (the arms deliberately disagree on name shape,
// count and declaration order).
package rep_pk;
  parameter R_1 = 31;
  parameter r_02 = 32;
endpackage

package mid_pk;
  parameter M_a = 41;
endpackage

package typeonly_pk;
  parameter type TY_only = bit [5:0];
endpackage

import rep_pk::*;
import mid_pk::M_a;
import rep_pk::*;
import typeonly_pk::*;
import rep_pk::r_02;

module e_ordering(output int eo);
  TY_only tv;
  assign eo = R_1 + r_02 + M_a + $bits(tv);
endmodule
