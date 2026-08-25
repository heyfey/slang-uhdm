// r10uvm148 arm B — THE SHADOWING SCOPE GRID.
// MEASUREMENT ONLY.  ONE production (TF-ITEM, the one this law moves) against
// FIVE outer scopes that could shadow a body local: a PACKAGE variable, a
// CLASS property, a `$unit` variable, a MODULE variable, and nothing at all.
// Surelog's `lateBinding` reaches only the package listing (its
// `inst->UhdmType() == uhdmpackage` guard), so only the package column may
// move; the other four are the fence.

// --- the $unit scope ---------------------------------------------------------
int    dunnage148;
string bollard148;

package scopepkg148;
  int    pkgside148;
  string bollard148;          // ALSO a $unit name: which scope wins is measured

  class Vellum148;
    int    clsside148;
    string bollard148;        // a CLASS property with the same name again

    // an IN-BODY class method (no vpiInstance at all)
    function void inbody_b148;
      int    clsside148;
      string bollard148;
      clsside148 = 3;
      bollard148 = "ferrule";
      $display("%0d %s", clsside148, bollard148);
    endfunction

    extern function void oob_b148;
  endclass

  // an OUT-OF-BODY class method (its vpiInstance IS the package)
  function void Vellum148::oob_b148;
    int    clsside148;
    int    pkgside148;
    string bollard148;
    clsside148 = 4;
    pkgside148 = 5;
    bollard148 = "quoin";
    $display("%0d %0d %s", clsside148, pkgside148, bollard148);
  endfunction

  // a package FREE function: package variable vs $unit variable vs nothing
  function void free_b148;
    int    pkgside148;
    int    dunnage148;
    string bollard148;
    int    unshadowed148;
    pkgside148    = 6;
    dunnage148    = 7;
    bollard148    = "mullion";
    unshadowed148 = 8;
    $display("%0d %0d %s %0d", pkgside148, dunnage148, bollard148,
             unshadowed148);
  endfunction
endpackage

// --- the MODULE scope --------------------------------------------------------
module scopemod148;
  int    modside148;
  string bollard148;

  function void mod_b148;
    int    modside148;
    string bollard148;
    int    dunnage148;
    modside148 = 9;
    bollard148 = "corbel";
    dunnage148 = 10;
    $display("%0d %s %0d", modside148, bollard148, dunnage148);
  endfunction

  task mod_t148;
    input int seed;
    int modside148;
    modside148 = seed;
    $display("%0d", modside148);
  endtask

  initial begin
    mod_b148();
    mod_t148(1);
  end
endmodule

module scopetop148;
  import scopepkg148::*;
  scopemod148 gudgeon148 ();
  Vellum148   parchment148;
  initial begin
    free_b148();
    parchment148 = new();
    parchment148.inbody_b148();
    parchment148.oob_b148();
  end
endmodule
