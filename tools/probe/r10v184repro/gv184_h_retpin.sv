// r10v184 VERIFIER ARM H — PINNING THE ARM-G EXCEPTION.
//
// Arm G found a pristine-right -> patched-wrong cell: in a WILDCARD-IMPORT
// CLONE, an argument that is the enclosing FREE FUNCTION's own RETURN NAME is
// bound by golden to the RETURN VARIABLE, not to the receiver — while in a
// CLASS method's clone the same spelling IS bound to the receiver.  This arm
// separates the candidate discriminators: class-vs-free, automatic-vs-static,
// out-of-body-vs-in-body, and whether the return name is written anywhere else
// in the body.
// Names, numbers and orders are deliberately unlike the corpus'.
package Tympanum605;

  class Archivolt605;
    int m_cusp;
    extern function int oob_static605(input int fml_a);
    extern function int oob_auto605(input int fml_b);
    function int inbody605(input int fml_c);
      string lintel;
      lintel = "lintelstone";
      inbody605 = 2;
      inbody605 = lintel.getc(inbody605);   // H5 class IN-BODY, return name arg
      return inbody605;
    endfunction
  endclass

  function int Archivolt605::oob_static605(input int fml_a);
    string mullion;
    mullion = "mullionstone";
    oob_static605 = 3;
    oob_static605 = mullion.getc(oob_static605); // H3 class OOB static
    return oob_static605 + fml_a;
  endfunction

  function int Archivolt605::oob_auto605(input int fml_b);
    string transom;
    transom = "transomstone";
    oob_auto605 = 4;
    oob_auto605 = transom.getc(oob_auto605);     // H4 class OOB automatic
    return oob_auto605 + fml_b;
  endfunction

  function int free_static605(input int fml_d);
    string corbel;
    corbel = "corbelstone";
    free_static605 = 5;
    free_static605 = corbel.getc(free_static605); // H2 FREE function, static
    return free_static605 + fml_d;
  endfunction

  function automatic int free_auto605(input int fml_e);
    string quoin;
    int    stud;
    quoin = "quoinstone";
    stud  = 6;
    free_auto605 = 7;
    free_auto605 = quoin.getc(free_auto605);      // H1 FREE function, automatic
    free_auto605 = quoin.getc(stud);              // H6 plain local, the control
    return free_auto605 + fml_e;
  endfunction

  // the return name never written anywhere but the argument
  function automatic int free_bare605(input int fml_f);
    string sill;
    sill = "sillstone";
    return sill.getc(free_bare605) + fml_f;       // H7 return name NEVER assigned
  endfunction

endpackage

// WILDCARD import — the clone path the law owns.
package Voussure605;
  import Tympanum605::*;
  int seen_voussure605 = 51;
  function automatic int use_voussure605();
    Archivolt605 rib;
    rib = new();
    return free_static605(1) + free_auto605(2) + free_bare605(3) +
           rib.oob_static605(4) + rib.oob_auto605(5) + rib.inbody605(6);
  endfunction
endpackage

module top605;
  import Voussure605::*;
  int tally605;
  initial begin
    tally605 = use_voussure605();
    $display("%0d", tally605);
  end
endmodule
