// r10uvm146 arm A — IMPORT FORMS at $unit scope.
// Four packages, four different import forms, deliberately UNALPHABETICAL
// declaration order and mixed case so a sorted listing cannot be confused
// with a declaration-order one.
package zeta_pk;
  parameter W_hi   = 8;
  parameter aa_low = 3;
  parameter MID_2  = 5;
endpackage

package alpha_pk;
  parameter Qq = 17;
  parameter bB = 4;
endpackage

package gamma_pk;
  parameter G_one = 1;
  parameter g_two = 2;
  parameter G_THREE = 3;
endpackage

package delta_pk;
  parameter D_only = 9;
  parameter D_other = 11;
endpackage

import zeta_pk::*;                 // wildcard
import alpha_pk::Qq;               // explicit, ONE item of two
import gamma_pk::*;                // wildcard AND
import gamma_pk::g_two;            //   an explicit of the same package

module a_forms(output int o1, output int o2, output int o3);
  // delta_pk is imported at MODULE scope only: it must NOT reach the design.
  import delta_pk::*;
  assign o1 = W_hi + aa_low;
  assign o2 = Qq + G_one;
  assign o3 = D_only + g_two;
endmodule
