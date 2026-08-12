// r10uvm62 arm c1 — THE DISCRIMINATOR ARM for class_defn's vpiEndLabel.
//
// One question in every row: does `endclass : <name>` put a vpiEndLabel on the
// class_defn, and does a bare `endclass` leave it off?  Every row is a CLASS in
// a different SCOPE / with a different QUALIFIER, so a rule that is really
// about the scope (package vs module vs unit) or about the qualifier (virtual /
// parameterized / extends) is separated from a rule that is really about the
// TOKEN after `endclass`.
//
// Paired rows are deliberate: each labelled class has an unlabelled twin in the
// SAME scope, so the discriminator cannot be the scope.

package p1;

  // R1 — package class, BARE endclass
  class A_bare;
    int x;
  endclass

  // R2 — package class, LABELLED endclass  (the uvm-1.2 shape)
  class A_lbl;
    int x;
  endclass : A_lbl

  // R3 — VIRTUAL class, labelled
  virtual class V_lbl;
    pure virtual function int f();
  endclass : V_lbl

  // R4 — VIRTUAL class, bare
  virtual class V_bare;
    pure virtual function int g();
  endclass

  // R5 — PARAMETERIZED class, labelled  (uvm_set_get_dap_base's shape)
  virtual class P_lbl #(type T = int);
    pure virtual function void set(T value);
    pure virtual function T get();
  endclass : P_lbl

  // R6 — PARAMETERIZED class, bare
  class P_bare #(int W = 8);
    logic [W-1:0] v;
  endclass

  // R7 — class that EXTENDS, labelled
  class E_lbl extends A_lbl;
    int y;
  endclass : E_lbl

  // R8 — class that EXTENDS, bare
  class E_bare extends A_lbl;
    int y;
  endclass

  // R9 — labelled class holding an EXTERN (out-of-block) method
  class X_lbl;
    int m;
    extern function int h();
  endclass : X_lbl

  function int X_lbl::h();
    return m;
  endfunction

endpackage

module m_top;

  // R10 — module-local class, labelled
  class M_lbl;
    int z;
  endclass : M_lbl

  // R11 — module-local class, bare
  class M_bare;
    int z;
  endclass

  // R12/R13 — NESTED class: outer labelled, inner labelled
  class N_out;
    class N_in;
      int q;
    endclass : N_in
    N_in h;
  endclass : N_out

  // R14/R15 — NESTED class: outer bare, inner bare
  class N2_out;
    class N2_in;
      int q;
    endclass
    N2_in h;
  endclass

  // R16 — a SPECIALIZATION of a labelled parameterized class is instantiated
  p1::P_bare #(4) pb4;
  p1::E_lbl el;

  initial begin
    pb4 = new();
    el = new();
  end

endmodule

// R17 — COMPILATION-UNIT (file scope) class, labelled
class U_lbl;
  int u;
endclass : U_lbl

// R18 — compilation-unit class, bare
class U_bare;
  int u;
endclass
