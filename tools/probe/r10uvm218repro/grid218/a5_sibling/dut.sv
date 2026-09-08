// r10uvm218 arm a5 — THE ONE CORPUS CELL THE LAW DOES NOT TAKE, isolated.
// svaunit_vpi_interface.sv:383 is
//    control_assertion_dpi(a_sva.get_sva_path(), `...KILL_ASSERTION, a_sim_time);
// a call STATEMENT whose FIRST argument is a RECEIVER-QUALIFIED method call and
// whose THIRD is a bare formal.  Golden binds that formal; we do not.  This arm
// separates the two features so the residue is characterised, not guessed.
class h518;
   function int get518(); return 1; endfunction
endclass

interface if518_un;                        // NEVER instantiated
   h518 hh518;

   function void f518(int a_p, int a_q);
      int loc518;
      sink518(a_p, a_q);                   // s01 both bare formals   (control)
      sink518(hh518.get518(), a_q);        // s02 a RECEIVER call as a SIBLING
                                           //     argument, formal beside it
      sink518(loc518518(), a_q);           // s03 a BARE call as a sibling
      sink518(a_p, hh518.get518());        // s04 the receiver call SECOND
      if (hh518.get518() == a_q) loc518=1; // s05 a receiver call in a COND,
                                           //     formal beside it
   endfunction

   function void sink518(int x, int y); endfunction
   function int  loc518518(); return 1; endfunction
endinterface

module top518;
   initial begin end
endmodule
