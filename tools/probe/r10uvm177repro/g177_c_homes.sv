// r10uvm177 grid arm C — WHERE the alias lives and WHERE the function lives.
// Arm A/B measured a package's own listing.  This arm varies the HOME of the
// declaration (module-local, $unit, foreign package, imported) against the HOME
// of the function, so the law's gate is measured on both axes rather than
// assumed from one home.
typedef enum { U_P, U_Q } unit_enum;      // $unit direct enum typedef
typedef unit_enum         UnitVia;        // $unit alias of it

package farpk177;
  typedef enum { F_M, F_N } far_enum;
  typedef far_enum          FarVia;       // alias, in the FOREIGN package
  typedef int               far_int;
  typedef far_int           FarIntVia;
endpackage

package nearpk177;
  import farpk177::*;
  typedef farpk177::far_enum ImportedVia;    // alias of a FOREIGN typedef
  typedef FarVia             ViaOfForeignVia; // alias of a foreign ALIAS
  typedef enum { N_S, N_T } near_enum;
  typedef near_enum          NearVia;

  // package free functions, four spellings of the return type
  function near_enum        h_direct();     return N_S; endfunction
  function NearVia          h_localvia();   return N_T; endfunction
  function ImportedVia      h_impvia();     return F_M; endfunction
  function ViaOfForeignVia  h_farvia();     return F_N; endfunction
  function farpk177::FarVia h_scopedvia();  return F_M; endfunction
  function farpk177::far_enum h_scopeddir(); return F_N; endfunction
  // NOTE: `function UnitVia h_unitvia();` inside a package is a $unit
  // reference slang rejects ("cannot reference compilation unit item from
  // within a package"); Surelog accepts it and answers `enum_var`.  The
  // reachable half of the same question is the module's `k_unitvia` below.
  function farpk177::FarIntVia h_scopedint(); return 7; endfunction
endpackage

module cmod177;
  import nearpk177::*;
  typedef enum { M_G, M_H } mod_enum;      // MODULE-local direct enum typedef
  typedef mod_enum          ModVia;        // MODULE-local alias

  function mod_enum   k_moddirect();  return M_G; endfunction
  function ModVia     k_modvia();     return M_H; endfunction
  function NearVia    k_impvia();     return N_S; endfunction
  function UnitVia    k_unitvia();    return U_Q; endfunction

  initial $display(k_moddirect(), k_modvia(), k_impvia(), k_unitvia(),
                   h_direct(), h_localvia(), h_impvia(), h_farvia(),
                   h_scopedint());
endmodule
