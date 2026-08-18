// r10earl68 arm a3 — the LHS-BIND dimension.  Surelog's
// `CompileHelper::bindVariable(component, const any* scope, ...)`
// (CompileStmt.cpp:3089) has cases for function / task / begin / module_inst
// ONLY: there is NO `uhdmgen_scope` and NO `uhdminterface_inst` case, so it
// walks a gen_scope's parent chain straight past every gen-local declaration
// and stops dead at an interface.  This arm measures that.  MEASUREMENT ONLY.
interface if_bind68;
  logic [7:0] iface_lvl;              // INTERFACE-level: bindVariable cannot see it
  for (genvar i = 0; i < 2; i++) begin : g_i
    logic [3:0] gen_lvl;              // gen-local: bindVariable cannot see it
    assign gen_lvl  = i;
    assign iface_lvl = i;
  end
endinterface

module a3_bind68 (input logic [7:0] pin, output logic [3:0] pout);
  logic [7:0]  mod_lvl;
  logic [3:0]  mod_nib;
  real         mod_real;
  logic [7:0]  ndecl_src;
  logic [7:0]  arr2 [0:3];
  for (genvar i = 0; i < 3; i++) begin : g_m
    logic [3:0] gen_lvl;              // gen-local
    if (i >= 0) begin : b1
      logic [5:0] deep_lvl;           // gen-local, one deeper
      assign gen_lvl  = i;            // gen-local Lhs, distance 1
      assign deep_lvl = i;            // gen-local Lhs, distance 0
      assign mod_lvl  = i;            // module-level Lhs (8)
      assign mod_nib  = i;            // module-level Lhs (4)
      assign pout     = i;            // module PORT Lhs (4)
      assign arr2[i]  = i;            // unpacked-array element Lhs
      assign mod_real = i;            // REAL Lhs
      logic [7:0] nda = i;            // NET-DECL-ASSIGN with a genvar Rhs
      assign ndecl_src = (i);         // PARENTHESISED bare genvar
    end
  end
  if_bind68 the_if ();
  assign pout = mod_lvl[3:0] ^ mod_nib ^ pin[3:0] ^
                the_if.iface_lvl[3:0] ^ the_if.g_i[0].gen_lvl ^
                g_m[0].gen_lvl ^ g_m[0].b1.deep_lvl[3:0] ^
                g_m[0].b1.nda[3:0] ^ ndecl_src[3:0] ^ arr2[0][3:0];
endmodule
