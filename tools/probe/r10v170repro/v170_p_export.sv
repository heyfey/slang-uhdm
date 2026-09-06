// r10v170 arm P — THE EXPORT-DECLARATION AXIS.  Nothing in r10uvm170's own five
// arms writes an ALIASED export (`export "DPI-C" cname = function svname;`), a
// DPI IMPORT prototype, a DOUBLE export, or an export whose subject is
// separated from it by other definitions.  Each is a way the detector
// `dpiExportPrecedesDef170` (which reads `DPIExportSyntax::name` and a member
// INDEX) could answer differently from Surelog.
//
// Names deliberately unlike the implementer's (no a_t/b_t/c_t, mixed case,
// numbers out of order) so an arm cannot agree by shape.
package Ordering7;
  typedef enum bit [2:0] { ZK_IDLE, ZK_RUN } Kappa_e;
  typedef enum bit [1:0] { QW_A, QW_B }      Omega_e;
  typedef struct packed { bit [5:0] w; }     Delta_s;
  typedef enum bit [1:0] { RR0, RR1 }        Sigma_e;
  typedef enum bit [1:0] { TT0, TT1 }        Tau_e;

  function void drain7(int q);
  endfunction

  // (P1) ALIASED export, C name != SV name, written ABOVE the definition.
  export "DPI-C" c_alias_alpha = function alpha7;
  function void alpha7(int v);
    drain7(int'(Kappa_e'(v)));        // p01  bare own enum  -> ?
    drain7(int'(Delta_s'(v)));        // p02  bare own struct
    drain7(int'(Ordering7::Kappa_e'(v))); // p03 scoped
  endfunction

  // (P2) ALIASED export for a TASK, written ABOVE the definition.
  export "DPI-C" c_alias_beta = task beta7;
  task beta7(int v);
    drain7(int'(Omega_e'(v)));        // p04  bare own enum, task body
  endtask

  // (P3) An export whose subject is separated from it by TWO other
  //      definitions.  gamma7 must degrade; the two in between must not.
  export "DPI-C" function gamma7;
  function void filler7a(int v);
    drain7(int'(Sigma_e'(v)));        // p05  NOT exported -> must resolve
  endfunction
  function void filler7b(int v);
    drain7(int'(Sigma_e'(v)));        // p06  NOT exported -> must resolve
  endfunction
  function void gamma7(int v);
    drain7(int'(Sigma_e'(v)));        // p07  exported, export above -> ?
  endfunction

  // (P4) A second, ordinary above-export, this one immediately adjacent.
  export "DPI-C" function delta7;
  function void delta7(int v);
    drain7(int'(Tau_e'(v)));          // p08
  endfunction

  // (P5) An export written BELOW, for a function whose body sits between two
  //      exports of OTHER names.  Must not degrade.
  function void epsil7(int v);
    drain7(int'(Tau_e'(v)));          // p09  export below -> must resolve
  endfunction
  export "DPI-C" function epsil7;
endpackage

module topP170;
  initial begin
    Ordering7::epsil7(3);
    Ordering7::filler7a(1);
  end
endmodule
