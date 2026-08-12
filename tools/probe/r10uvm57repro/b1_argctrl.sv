// r10uvm57repro/b1_argctrl.sv -- THE REAL WITNESS ARM.  The head is NOT a
// missing object (see README §1): both sides emit the block-scoped string_var.
// It is an UNBOUND USER-CALL ARGUMENT under § controlBodyNoBind28.
//
// Every cell is a USER function-call argument inside a class method.  The
// question is which symbol classes bind at ctrlBodyDepth28 > 0.
package pb1;
  function automatic void sink(string s);
    $display(s);
  endfunction
  function automatic void sinki(int i);
    $display(i);
  endfunction

  class ib;                      // IN-BODY method
    string prop;
    static function int f(int obj, string farg);
      string bodyloc;            // METHOD-BODY local
      bodyloc = "b";
      f = obj;
      // ---- DEPTH 0 (no control body): classArgBind12's own window ----
      sink(bodyloc);              // d0 body-local
      sink(farg);                 // d0 formal
      sinki(obj);                 // d0 formal int
      // ---- DEPTH 1: inside an unnamed if-body block ----
      if (obj == 0) begin
        string blkloc;            // BLOCK-SCOPE local  <- the uvm shape
        blkloc = "k";
        sink(blkloc);             // d1 BLOCK local        <-- THE CELL
        sink(bodyloc);            // d1 body-local
        sink(farg);               // d1 formal
        sinki(obj);               // d1 formal int
        $display(blkloc);         // d1 SYSTEM call arg (control)
        blkloc = bodyloc;         // d1 assignment (control: both bare)
      end
      // ---- DEPTH 1, NO declaration in the block ----
      if (obj == 1) begin
        sink(bodyloc);
        sink(farg);
      end
    endfunction

    function int g(int obj);      // non-static, same shape
      g = obj;
      if (obj == 0) begin
        string gblk;
        gblk = "g";
        sink(gblk);
        sink(prop);               // class PROPERTY (never binds anywhere)
      end
    endfunction
  endclass

  class ob;                       // OUT-OF-BODY method
    extern static function int f(int obj, string farg);
  endclass
  function int ob::f(int obj, string farg);
    string bodyloc;
    bodyloc = "b";
    f = obj;
    sink(bodyloc);
    if (obj == 0) begin
      string blkloc;
      blkloc = "k";
      sink(blkloc);
      sink(bodyloc);
      sink(farg);
    end
  endfunction

  // PACKAGE FREE FUNCTION control -- no class scope at all
  function automatic int pf(int obj, string farg);
    string bodyloc;
    bodyloc = "b";
    pf = obj;
    sink(bodyloc);
    if (obj == 0) begin
      string blkloc;
      blkloc = "k";
      sink(blkloc);
      sink(bodyloc);
      sink(farg);
    end
  endfunction
endpackage

module b1_argctrl;
  import pb1::*;
  int q;
  // MODULE FUNCTION control
  function automatic int mf(int obj, string farg);
    string bodyloc;
    bodyloc = "b";
    mf = obj;
    pb1::sink(bodyloc);
    if (obj == 0) begin
      string blkloc;
      blkloc = "k";
      pb1::sink(blkloc);
      pb1::sink(bodyloc);
      pb1::sink(farg);
    end
  endfunction
  initial q = pb1::pf(0, "x") + mf(0, "y");
endmodule
