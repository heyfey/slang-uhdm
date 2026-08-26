// r10uvm158 grid, arm B — WHAT THE LOCAL IS, inside a block slang REJECTED.
//
// THE POPULATION.  A statement slang rejects with a REPORTED diagnostic makes
// the whole test `SLANG_REJECT` and is out of the campaign's scope; the
// population this law reaches is the statement slang binds BAD in SILENCE —
// the body of a GENERIC CLASS's DEFAULT specialization, which nothing in the
// source ever specializes and which slang therefore never diagnoses (our
// emitter is what asks for it, after the diagnostics are collected).  That is
// exactly `uvm_pkg::uvm_reg_predictor`.  Every `Bad158` block below is
// rejected for the DEFAULT binding of the class's type parameter and for that
// binding only.
//
// The law is about the BLOCK's scope, not the local's type, so every declared
// form is measured in the SAME rejected block: a type parameter defaulted to
// int, one defaulted to a CLASS, a typedef OF a type parameter, an array of
// the parameter, and plain built-in / string / class / enum / struct locals
// that have nothing to do with a type parameter at all.
package pb158;

  class payl158;
    int q158 = 3;
    static function payl158 mk158(string s); mk158 = new(); endfunction
    function string nm158(); return "payl"; endfunction
  endclass

  typedef enum {EA158, EB158} en158;
  typedef struct packed { bit [3:0] f158; } st158;

  class typeB158 #(type T = int, type U = payl158);
    typedef T alias158;
    string sink158 = "";

    // ONE rejected block, EVERY local form in it, in declaration order.
    function void allBad158();
      begin
        T           tp158;      // the type parameter, default int
        U           cp158;      // the type parameter, default a CLASS
        alias158    al158;      // a typedef OF the type parameter
        T           ar158 [3];  // a parameter-typed unpacked array
        int         pi158;      // a plain built-in
        string      ps158;      // a string
        payl158     pc158;      // a directly named class
        en158       pe158;      // an enum typedef
        st158       pt158;      // a struct typedef
        bit [7:0]   pv158;      // a packed vector
        tp158 = T::mk158("tp158");
        pi158 = 1;
      end
    endfunction

    // the SAME declaration set in an ACCEPTED block — the control that must
    // stay byte-identical.
    function void allOk158();
      begin
        T           tq158;
        U           cq158;
        alias158    aq158;
        T           aq2158 [3];
        int         qi158;
        string      qs158;
        payl158     qc158;
        en158       qe158;
        st158       qt158;
        bit [7:0]   qv158;
        qi158 = 1;
      end
    endfunction

    // a rejected block whose ONLY local is NOT parameter-typed at all.
    function void plainBad158();
      begin
        int pb2158;
        pb2158 = T::mk158("x");
      end
    endfunction

    // a rejected block with a WITH-INITIALISER local.
    function void initBad158();
      begin
        int ib2158 = 7;
        ib2158 = T::mk158("y");
      end
    endfunction
  endclass

  // THE OVERRIDE PAIR.  The SAME block shape in a class that IS specialized:
  // the DEFAULT specialization (T=int) binds it BAD and the `#(payl158)` one
  // binds it GOOD, so one source line gives both answers in one database.
  class ovB158 #(type T = int);
    function void ovBody158();
      begin
        T ov158;
        int ovi158;
        ov158 = T::mk158("ov158");
        ovi158 = 2;
      end
    endfunction
  endclass

endpackage

module topb158;
  import pb158::*;
  ovB158 #(payl158) sp158;
  initial begin
    sp158 = new();
    sp158.ovBody158();
  end
endmodule
