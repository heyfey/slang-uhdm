// r10uvm148 arm C — THE HOME GRID, and the WILDCARD-IMPORT COPY.
// MEASUREMENT ONLY.  § pkgSubRefBindsPkgVarOverFormal81's home gate says the
// overwrite belongs to the package that OWNS the subroutine, never to an
// importer that materialised a COPY of it.  This arm puts the same TF-ITEM
// body in eight homes and then imports the whole package into a second one.
package homefrom148;
  int     tureen;
  string  wicket;
  int     spandrel;

  class Corbie148;
    int prop;
    extern function void oob_c148;
    extern task          oobt_c148(input int seed);
    function void inbody_c148;          // written INSIDE the class body
      int    tureen;
      string wicket;
      tureen = 21;
      wicket = "escutcheon";
      $display("%0d %s", tureen, wicket);
    endfunction
    // a CLASS CONSTRUCTOR, paren-less, written inside the body
    function new;
      int tureen;
      tureen = 22;
      prop   = tureen;
    endfunction
  endclass

  function void Corbie148::oob_c148;    // OUT OF BODY, paren-less -> TF-ITEM
    int    tureen;
    string wicket;
    tureen = 23;
    wicket = "voussoir";
    $display("%0d %s", tureen, wicket);
  endfunction

  task Corbie148::oobt_c148;            // OUT OF BODY task, body io -> TF-ITEM
    input int seed;
    int spandrel;
    spandrel = seed;
    $display("%0d", spandrel);
  endtask

  function void freefn_c148;            // package FREE function, TF-ITEM
    int    tureen;
    string wicket;
    tureen = 24;
    wicket = "abacus";
    $display("%0d %s", tureen, wicket);
  endfunction

  task freetk_c148;                     // package FREE task, body io -> TF-ITEM
    input int seed;
    int spandrel;
    spandrel = seed;
    $display("%0d", spandrel);
  endtask
endpackage

// The IMPORTER: a wildcard import materialises a COPY of homefrom148's
// subroutines and CLONES of its variables.  § 81's home gate keeps the COPY's
// locals bound to the copy's own locals.
package hometo148;
  import homefrom148::*;
  export homefrom148::*;
  int tureen;

  function void own_c148;               // hometo148's OWN TF-ITEM subroutine
    int tureen;
    tureen = 25;
    $display("%0d", tureen);
  endfunction
endpackage

module homemod148;
  int tureen;
  function void modfn_c148;             // a MODULE function, TF-ITEM
    int tureen;
    tureen = 26;
    $display("%0d", tureen);
  endfunction
  task modtk_c148;                      // a MODULE task, body io -> TF-ITEM
    input int seed;
    int tureen;
    tureen = seed;
    $display("%0d", tureen);
  endtask
  initial begin modfn_c148(); modtk_c148(1); end
endmodule

program homeprog148;
  int tureen;
  function void progfn_c148;
    int tureen;
    tureen = 27;
    $display("%0d", tureen);
  endfunction
  initial progfn_c148();
endprogram

interface homeifc148;
  int tureen;
  function void ifcfn_c148;
    int tureen;
    tureen = 28;
    $display("%0d", tureen);
  endfunction
endinterface

module hometop148;
  import homefrom148::*;
  import hometo148::*;
  homemod148   pintle148 ();
  homemod148   gudgeon148 ();          // a SECOND instance of the same module
  homeifc148   hasp148 ();
  Corbie148    rowlock148;
  initial begin
    freefn_c148();
    freetk_c148(2);
    own_c148();
    rowlock148 = new();
    rowlock148.inbody_c148();
    rowlock148.oob_c148();
    rowlock148.oobt_c148(3);
  end
endmodule
