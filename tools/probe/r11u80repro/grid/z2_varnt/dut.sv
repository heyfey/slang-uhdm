// r11u80 z2 -- THE VAR QUALIFIER x THE BASE KEYWORDS, def-view vpiNetType
// (LAW B).  vi_defnt measured fifteen spellings and found ONE where
// § caImportedPkgDefNetType77's "written base keyword through one typedef
// hop" and golden part company: `var logic [7:0]` keeps 36 where golden
// stamps none.  This arm asks the var qualifier against every base keyword
// the rule can answer for, with the unqualified spelling beside it as the
// control, plus `const` and `static`/`automatic` for the boundary.
package pv2;
  typedef logic [3:0] w_t;     // a typedef whose base keyword IS logic
  typedef reg   [3:0] r_t;     // ... and reg
  typedef struct packed { logic [7:0] x; } s_t;

  // the CONTROLS: no qualifier (measured 36 / 48 / 36 / 48 / none)
  logic [7:0]   c_log;
  reg   [7:0]   c_reg;
  w_t           c_tdw;
  r_t           c_tdr;
  s_t           c_sct;

  // the VAR qualifier on each
  var logic [7:0]  v_log;
  var reg   [7:0]  v_reg;
  var w_t          v_tdw;
  var r_t          v_tdr;
  var s_t          v_sct;
  var              v_bare;     // `var` with an implicit data type
  var int          v_int;
  var bit   [3:0]  v_bit;

  // the CONST qualifier, with and without var
  const logic [7:0] k_log = 8'd1;
  const var logic [7:0] k_varlog = 8'd2;
endpackage

module dut (output logic [31:0] o);
  import pv2::*;
  assign o = {24'd0, c_log} ^ {24'd0, c_reg} ^ {28'd0, c_tdw}
           ^ {28'd0, c_tdr} ^ {24'd0, c_sct.x}
           ^ {24'd0, v_log} ^ {24'd0, v_reg} ^ {28'd0, v_tdw}
           ^ {28'd0, v_tdr} ^ {24'd0, v_sct.x} ^ {31'd0, v_bare}
           ^ v_int ^ {28'd0, v_bit}
           ^ {24'd0, k_log} ^ {24'd0, k_varlog};
endmodule
