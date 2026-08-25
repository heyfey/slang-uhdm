// r10v148 arm A — PRODUCTION (TF-ITEM vs BLOCK-ITEM) x REFERENCE ROLE,
// package-scope free subroutines, every local shadowing a PACKAGE variable.
// MEASUREMENT ONLY.
package v1_pkg;

  class base_v1;
    int fld;
    function int getf; return fld; endfunction
  endclass

  class deri_v1 extends base_v1;
    int extra;
  endclass

  int      rho;
  int      sig [4];
  base_v1  han;
  deri_v1  dhn;
  int      kap;

  // ---- TF-ITEM function: paren-less header ----
  function void tfi_v1;
    int      rho;
    int      sig [4];
    base_v1  han;
    deri_v1  dhn;
    int      kap;
    rho = 3;
    kap = rho + 1;
    $display("%0d", rho);
    sig[rho] = 2;
    han = new();
    kap = han.getf();
    foreach (sig[i]) kap = i;
    if (rho == 1) kap = 9;
    void'($cast(dhn, han));
  endfunction

  // ---- BLOCK-ITEM function: port-list paren ----
  function void bki_v1();
    int      rho;
    int      sig [4];
    base_v1  han;
    deri_v1  dhn;
    int      kap;
    rho = 3;
    kap = rho + 1;
    $display("%0d", rho);
    sig[rho] = 2;
    han = new();
    kap = han.getf();
    foreach (sig[i]) kap = i;
    if (rho == 1) kap = 9;
    void'($cast(dhn, han));
  endfunction

  // ---- TF-ITEM task: body declares io ----
  task tfi_t_v1;
    input int seed;
    int rho;
    int kap;
    rho = seed;
    kap = rho;
    if (rho == 2) kap = 4;
  endtask

  // ---- BLOCK-ITEM task: paren-less, no io in the body ----
  task bki_t_v1;
    int rho;
    int kap;
    rho = 1;
    kap = rho;
    if (rho == 2) kap = 4;
  endtask

  // ---- TF-ITEM function whose reference is the RETURN VALUE name ----
  function int tfi_ret_v1;
    int kap;
    kap = 7;
    tfi_ret_v1 = kap;
  endfunction

endpackage

module v148_a_top;
  initial begin
    v1_pkg::tfi_v1();
    v1_pkg::bki_v1();
  end
endmodule
