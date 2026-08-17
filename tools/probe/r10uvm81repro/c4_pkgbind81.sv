// r10uvm81 arm c4 — WHICH object a ref inside a PACKAGE-SCOPE subroutine binds
// to when its simple name ALSO names a variable in the PACKAGE's own
// vpiVariables listing.  The corpus head is cell A verbatim
// (uvm_pkg::uvm_sequencer_base::set_arbitration's `val`).
package p81;

  int    pdecl;                       // a DECLARED package variable
  string sdecl;

  class c81;
    int    m_a;
    string m_s;
    extern function new();
    extern function void set_val(int val);        // A: io_decl vs HOISTED pkg var
    extern function void set_pdecl(int pdecl);    // B: io_decl vs DECLARED pkg var
    extern function void set_free(int freearg);   // C: control, no collision
    extern task          tset_val(int val);       // D: TASK arm
    extern function void loc_val();               // E: METHOD LOCAL vs hoisted pkg var
    function void inbody_val(int val);            // F: IN-BODY method, collision
      m_a = val;
    endfunction
    function void inbody_free(int freearg);       // G: IN-BODY control
      m_a = freearg;
    endfunction
  endclass

  // The HOISTING site: an out-of-body body's begin-block locals are lifted into
  // the PACKAGE's variable listing (this is uvm_phase.svh:801/802 verbatim).
  function c81::new();
    begin
      string val;
      val = "x";
      m_s = val;
    end
  endfunction

  function void c81::set_val(int val);
    m_a = val;                                    // CELL A
  endfunction

  function void c81::set_pdecl(int pdecl);
    m_a = pdecl;                                  // CELL B
  endfunction

  function void c81::set_free(int freearg);
    m_a = freearg;                                // CELL C
  endfunction

  task c81::tset_val(int val);
    m_a = val;                                    // CELL D
  endtask

  function void c81::loc_val();
    int val;
    val = 7;
    m_a = val;                                    // CELL E
  endfunction

  // A PLAIN package subroutine (not a class method) — same package scope.
  function void pf_val(int val);
    pdecl = val;                                  // CELL H
  endfunction

  function void pf_pdecl(int pdecl);
    sdecl = "y";
    pdecl = 1;                                    // CELL I
  endfunction

  function void pf_free(int freearg);
    pdecl = freearg;                              // CELL J
  endfunction

endpackage

module mdl81;
  import p81::*;
  int   mv;
  logic val;                                      // MODULE-scope object named val
  function void mf_val(int val);
    mv = val;                                     // CELL K — module twin
  endfunction
  function void mf_free(int freearg);
    mv = freearg;                                 // CELL L — module control
  endfunction
  initial begin
    mv = 0;
    mf_val(1);
    mf_free(2);
  end
endmodule
