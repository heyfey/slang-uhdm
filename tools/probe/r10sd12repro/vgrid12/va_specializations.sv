// vsd12 cell va — THE DECLARING CLASS IS GENERIC, WITH TWO SPECIALIZATIONS.
// The standing ops rule is that a MINTED specialization can flip a value that
// only a per-shape table sees, and that no probe or emit path may ever ask for
// `getDefaultSpecialization`.  `declArrayElemVarKind12` reads only the
// declaration symbol, its syntax and its declared type — but the DECLARING
// class it walks up to is a SPECIALIZATION ClassType, and r10sd10's ORDER term
// compares `owner.name < ctx.cls->name`, so the two specializations must give
// the SAME answer and the generic must not acquire a third.
package pva;

  class zela;
    int q;
  endclass

  class zowna;                        // sorts AFTER `guser` -> ClassVar arm
    typedef zela d_t;
  endclass

  class ausera #(type T = int);       // sorts BEFORE `zowna`
    typedef zela own_t;
    function void fa();
      zowna::d_t g_q[$];              // scoped, LATE owner
      zowna::d_t g_s;
      own_t      b_q[$];              // bare own typedef, in-body
      own_t      b_s;
      g_q = {};
      b_q = {};
    endfunction
  endclass

  class drivera;
    function void go();
      ausera#(int)    a1 = new();
      ausera#(byte)   a2 = new();
      a1.fa();
      a2.fa();
    endfunction
  endclass

endpackage

module topva;
  initial begin
    pva::drivera d = new();
    d.go();
  end
endmodule
