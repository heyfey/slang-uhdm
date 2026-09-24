// r10uvm148 arm D — KINDS x LIFETIMES.
// MEASUREMENT ONLY.  The same shadow race in every variable kind the corpus
// carries and in all three written lifetimes, under BOTH productions.  The
// head's own cell is a CLASS HANDLE (`uvm_coreservice_t cs`) written with no
// lifetime keyword at all.
package kindpkg148;
  typedef enum { PENNON, GONFALON, ORIFLAMME } banner_e;

  class Latten148;
    int fettle;
    function int knurl(int k); fettle = fettle + k; return fettle; endfunction
  endclass

  // the shadowed package-scope names, one per kind
  Latten148    hasp;
  int          fillet;
  string       chamfer;
  bit  [3:0]   nogging;
  real         plinth;
  banner_e     oriel;
  logic [7:0]  reveal;

  // ---- TF-ITEM, no written lifetime ----------------------------------------
  function void tf_kinds148;
    Latten148   hasp;
    int         fillet;
    string      chamfer;
    bit [3:0]   nogging;
    real        plinth;
    banner_e    oriel;
    logic [7:0] reveal;
    hasp    = new();
    fillet  = hasp.knurl(2);
    chamfer = "newel";
    nogging = 4'hb;
    plinth  = 2.5;
    oriel   = GONFALON;
    reveal  = 8'h5a;
    $display("%0d %s %0d %f %0d", fillet, chamfer, nogging, plinth, reveal);
  endfunction

  // ---- BLOCK-ITEM, no written lifetime -------------------------------------
  function void bi_kinds148();
    Latten148   hasp;
    int         fillet;
    string      chamfer;
    bit [3:0]   nogging;
    real        plinth;
    banner_e    oriel;
    logic [7:0] reveal;
    hasp    = new();
    fillet  = hasp.knurl(2);
    chamfer = "newel";
    nogging = 4'hb;
    plinth  = 2.5;
    oriel   = GONFALON;
    reveal  = 8'h5a;
    $display("%0d %s %0d %f %0d", fillet, chamfer, nogging, plinth, reveal);
  endfunction

  // ---- TF-ITEM, written STATIC ---------------------------------------------
  function void tf_static148;
    static int    fillet = 0;
    static string chamfer = "";
    fillet  = fillet + 1;
    chamfer = "transom";
    $display("%0d %s", fillet, chamfer);
  endfunction

  // ---- TF-ITEM, written AUTOMATIC ------------------------------------------
  function void tf_auto148;
    automatic int    fillet = 0;
    automatic string chamfer = "";
    fillet  = fillet + 1;
    chamfer = "mutule";
    $display("%0d %s", fillet, chamfer);
  endfunction

  // ---- BLOCK-ITEM, written STATIC / AUTOMATIC ------------------------------
  function void bi_static148();
    static int    fillet = 0;
    static string chamfer = "";
    fillet  = fillet + 1;
    chamfer = "transom";
    $display("%0d %s", fillet, chamfer);
  endfunction

  function void bi_auto148();
    automatic int    fillet = 0;
    automatic string chamfer = "";
    fillet  = fillet + 1;
    chamfer = "mutule";
    $display("%0d %s", fillet, chamfer);
  endfunction

  // ---- a subroutine whose own NAME is a package variable name --------------
  int fascia;
  function int fascia148;             // the RETURN value shares the fn's name
    int fascia;
    fascia   = 3;
    fascia148 = fascia;
    return fascia148;
  endfunction
endpackage

module kindtop148;
  import kindpkg148::*;
  initial begin
    tf_kinds148();
    bi_kinds148();
    tf_static148();
    tf_auto148();
    bi_static148();
    bi_auto148();
    $display("%0d", fascia148());
  end
endmodule
