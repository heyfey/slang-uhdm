// v11u84 v6 — THE MODULE-SIDE CONTROL (the sister pass's ground, measured not
// fixed).  A module that imports a package materialises the SAME clone (the
// module hoist, § collectImportedPkgVars).  If LAW A ("a clone reads the
// ELABORATED entry in either view") is a property of the POINTER and not of
// the package writer, golden's MODULE-side clone must carry nt 36 in the DEF
// view too.  This arm asks whether r11u84's package-only fence leaves a
// module-side residue — and it must not MOVE between the two binaries.
package mc1;
  typedef logic [7:0] mw_t;
  wire  mw_t  c_wtd;             // 1 hop: def nt 1, elab nt 36
  typedef mw_t mw2_t;
  wire  mw2_t c_wtd2;            // 2 hops: nt 1 in both
  typedef bit [3:0] mb_t;
  typedef mb_t mb2_t;
  mb2_t c_b2;                    // 2 hops bit: logic_net in def, bit_var elab
  logic [7:0] c_var = 8'd2;
endpackage

package mc2;                     // the package-side control for the same cells
  import mc1::*;
endpackage

module dut (output logic [31:0] o);
  import mc1::*;                 // the MODULE-side clone of the same entries
  assign o = {24'd0, c_wtd ^ c_var};
endmodule

module dut2 (output logic [7:0] o2);
  import mc1::c_wtd2;            // a module-side EXPLICIT clone
  assign o2 = c_wtd2;
endmodule
