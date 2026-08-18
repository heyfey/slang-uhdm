// r10buvm17 arm a1 — A PACKAGE AND NOTHING ELSE, exactly BuildUVMPkg's shape
// (no top module anywhere, so Surelog writes an un-elaborated `allPackages`
// listing and an elaborated `topPackages` listing and nothing else).
//
// The question every cell asks: does a body reference to a FOREACH LOOP
// VARIABLE carry `vpiActual` pointing at the object the loop lists in
// `vpiLoopVars`, and does the answer depend on the variable's KIND?
//
// MEASUREMENT ONLY.  Nothing here is an acceptance judge.
package pk17;

  typedef struct packed { bit [7:0] a17; bit [7:0] b17; } st17_t;

  int pkgint17;

  class D17;
    int d17;
    function int val17(); return d17; endfunction
  endclass

  class C17;
    int      m_int_q17[$];
    string   m_str17;
    byte     m_byte_d17[];
    D17      m_cls_q17[$];
    st17_t   m_st_q17[$];
    int      m_assoc17[string];
    D17      m_acls17[string];
    int      m_bycls17[D17];

    extern function void k_byte17  (ref byte unsigned s17[]);
    extern function void k_long17  (ref longint unsigned l17[]);
    extern function void k_bit17   (ref bit [15:0] b17v[]);
    extern function void k_short17 (ref shortint sh17[]);
    extern function void k_real17  (ref real r17[]);
    extern function void k_str17   (string t17);
    extern function void k_cls17   (ref D17 c17[$]);
    extern function void k_struct17(ref st17_t u17[$]);
    extern function void k_int17   (ref int i17q[]);
    extern function void k_assoc17 ();
    extern function void k_clsidx17();
    extern function void k_nest17  (ref byte n17[], ref byte m17[]);
    extern function void k_multi17 (ref byte g17[3][4]);
    extern function void k_shadow17(ref byte p17[]);
    extern function void k_dotted17(ref D17 q17[$]);
    extern task          k_task17  (ref byte tk17[]);
    extern static function void k_static17(ref byte st17[]);

    // THE IN-BODY CONTROL: § classMethodNoBind leaves the whole body bare in
    // BOTH views, loop variable included, and this pass must not change that.
    function void k_inbody17(ref byte ib17[]);
      int acc17 = 0;
      foreach (ib17[i]) acc17 = acc17 + i;
    endfunction
  endclass

  // ---- the KIND grid.  Every one of these is an OUT-OF-BODY definition, the
  // shape uvm_packer::get_packed_bytes has.
  function void C17::k_byte17(ref byte unsigned s17[]);
    int sz17 = 0;
    foreach (s17[i]) begin
      if (i != sz17 - 1) sz17 = sz17 + 1;   // operation operand
      s17[i] = 8'h0;                        // bit-select INDEX, assignment LHS
      $display("%0d", i);                   // sys-call argument
    end
  endfunction

  function void C17::k_long17(ref longint unsigned l17[]);
    longint unsigned a17 = 0;
    foreach (l17[i]) a17 = a17 + l17[i] + i;
  endfunction

  function void C17::k_bit17(ref bit [15:0] b17v[]);
    int a17 = 0;
    foreach (b17v[i]) a17 = a17 + b17v[i];
  endfunction

  function void C17::k_short17(ref shortint sh17[]);
    int a17 = 0;
    foreach (sh17[i]) a17 = a17 + sh17[i] + i;
  endfunction

  function void C17::k_real17(ref real r17[]);
    real a17 = 0.0;
    foreach (r17[i]) a17 = a17 + r17[i];
  endfunction

  function void C17::k_str17(string t17);
    int a17 = 0;
    foreach (t17[i]) a17 = a17 + t17[i];    // a STRING is iterated by character
  endfunction

  function void C17::k_cls17(ref D17 c17[$]);
    int a17 = 0;
    foreach (c17[i]) a17 = a17 + i;
  endfunction

  function void C17::k_struct17(ref st17_t u17[$]);
    int a17 = 0;
    foreach (u17[i]) a17 = a17 + u17[i].a17;
  endfunction

  function void C17::k_int17(ref int i17q[]);
    int a17 = 0;
    foreach (i17q[i]) a17 = a17 + i17q[i] + i;   // the ALREADY-BOUND int shape
  endfunction

  function void C17::k_assoc17();
    int a17 = 0;
    foreach (m_assoc17[s]) a17 = a17 + m_assoc17[s];   // [string] index
    foreach (m_acls17[c]) a17 = a17 + 1;               // [class] index
  endfunction

  // THE PATH-BASE CONTROL.  An associative array indexed by a CLASS HANDLE
  // gives a loop variable that is itself a handle, so the body can use it as
  // the BASE of a dotted path and as a method-call RECEIVER -- the two
  // positions golden leaves BARE even in the elaborated view (60 hier_path and
  // 13 method_func_call cells in BuildUVMPkg).  This pass must not bind them.
  function void C17::k_clsidx17();
    int a17 = 0;
    foreach (m_bycls17[c]) begin
      a17 = a17 + c.d17;        // the loop variable as a hier_path BASE
      a17 = a17 + c.val17();    // ...and as a method-call RECEIVER
      a17 = a17 + m_bycls17[c]; // ...and as a plain bit-select INDEX
    end
  endfunction

  function void C17::k_nest17(ref byte n17[], ref byte m17[]);
    int a17 = 0;
    foreach (n17[i]) begin
      foreach (m17[j]) a17 = a17 + i + j;              // NESTED, two loop vars
    end
  endfunction

  function void C17::k_multi17(ref byte g17[3][4]);
    int a17 = 0;
    foreach (g17[i,j]) a17 = a17 + g17[i][j] + i + j;  // TWO loop vars at once
  endfunction

  function void C17::k_shadow17(ref byte p17[]);
    int i = 7;                                          // SHADOWED by the loop
    int a17 = 0;
    foreach (p17[i]) a17 = a17 + i;
  endfunction

  function void C17::k_dotted17(ref D17 q17[$]);
    int a17 = 0;
    foreach (q17[o]) begin
      a17 = a17 + q17[o].d17;      // the loop var as a bit-select INDEX
      a17 = a17 + q17[o].val17();  // ...and inside a method call
    end
  endfunction

  task C17::k_task17(ref byte tk17[]);
    int a17 = 0;
    foreach (tk17[i]) a17 = a17 + i;
  endtask

  function void C17::k_static17(ref byte st17[]);
    int a17 = 0;
    foreach (st17[i]) a17 = a17 + i;
  endfunction

  // ---- a PACKAGE FREE FUNCTION and a PACKAGE TASK, same body.
  function automatic void free17(ref byte fb17[]);
    int a17 = 0;
    foreach (fb17[i]) a17 = a17 + i;
  endfunction

  task automatic freetask17(ref byte ft17[]);
    int a17 = 0;
    foreach (ft17[i]) a17 = a17 + i;
  endtask

  function automatic void freestr17(string fs17);
    int a17 = 0;
    foreach (fs17[i]) a17 = a17 + fs17[i];
  endfunction

endpackage
