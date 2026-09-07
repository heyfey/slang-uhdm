// r10v188repro/arms/v188_d_scopes.sv — ADVERSARIAL HOMES.
// The same three shapes in a $unit enum (which the law FENCES OUT and
// § unitArith/§ unitArithShape own), a package, a class inside that package,
// a module, an interface, a function-local typedef, a generate block, and an
// IMPORT-LISTING CLONE (the module that imports the package) — plus the
// REFERENCE sites (R1) where a folded `constant` inherits the enum constant's
// fields.
typedef enum { D_U_A = 1 << 4, D_U_B = 3 + 5, D_U_C = 9 - 2 } d_unit_e;

package v188d_pkg;
  typedef enum { D_P_A = 1 << 4, D_P_B = 3 + 5, D_P_C = 9 - 2 } d_pkg_e;
  typedef enum bit [7:0] { D_Q_A = 1 << 5, D_Q_B = 3 + 6,
                           D_Q_C = 9 - 3 } d_pkg2_e;
  class d_cls;
    typedef enum { D_C_A = 1 << 4, D_C_B = 3 + 5, D_C_C = 9 - 2 } d_cls_e;
    d_cls_e cm;
  endclass
endpackage

interface v188d_if;
  typedef enum { D_I_A = 1 << 4, D_I_B = 3 + 5, D_I_C = 9 - 2 } d_if_e;
  d_if_e im;
endinterface

module v188d_top;
  import v188d_pkg::*;
  typedef enum { D_M_A = 1 << 4, D_M_B = 3 + 5, D_M_C = 9 - 2 } d_mod_e;
  d_mod_e mm;
  d_pkg_e pm;
  d_pkg2_e qm;

  // R1: reference sites — a folded `constant` inheriting an enum constant.
  localparam int D_REF0 = D_P_A;
  localparam int D_REF1 = v188d_pkg::D_P_B;
  int z0;
  initial z0 = D_P_C;

  function automatic int d_fn();
    typedef enum { D_F_A = 1 << 4, D_F_B = 3 + 5, D_F_C = 9 - 2 } d_fn_e;
    d_fn_e fv = D_F_A;
    return int'(fv);
  endfunction

  for (genvar gi = 0; gi < 2; gi++) begin : d_gen
    typedef enum { D_G_A = 1 << 4, D_G_B = 3 + 5, D_G_C = 9 - 2 } d_gen_e;
    d_gen_e gm;
  end
endmodule
