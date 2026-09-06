// r10uvm179 arm A — THE FACE AND ITS NEIGHBOURS, for
// § recvCallArgRefVarLocalNeverBinds179.  MEASUREMENT ONLY; the official
// `uhdm-cmp` is the sole judge of equality.
//
// THE CORPUS SHAPE, reproduced: a PACKAGE class with a TYPE PARAMETER, an
// OUT-OF-BODY method holding a local of that parameter's type (which Surelog
// emits as a `ref_var`, § refVarLocalWindowBinds5's own object), and a call
// on a ONE-NAME RECEIVER standing in EXPRESSION position inside an `if`
// CONDITION.  That is uvm-1.2 `uvm_sequencer_param_base::send_request`'s
//     REQ param_t;                              // :270
//     if (m_req_fifo.try_put(param_t) != 1)     // :297
// verbatim, and `uvm_sequencer::item_done`'s `m_req_fifo.try_get(t)` at :284.
//
// The module wildcard-imports the package so Surelog's
// `UhdmWriter::lateBinding` has a module to mint an implicit wire into — the
// SECOND listing of every body, which is § oobRefVarLocalHoistNet107's and must
// not move.
//
// Cells are named `<axis>_<what>` and every one of them is READ OFF ONE GOLDEN.
package pa179;

  class d179;
    int fld;
    function int m(int a); return a; endfunction
  endclass

  class sink179;
    function void take(d179 v); endfunction
    function int  ask(d179 v); return 0; endfunction
    function int  ask2(d179 v, int k); return k; endfunction
    task tk(d179 v); endtask
  endclass

  class c179 #(type T = d179);
    sink179 s;
    d179    plain;
    d179    qv[$];
    int     amap[d179];
    int     w;

    // THE FACE and the positions around it.
    extern function void f_cond();        // if CONDITION, expression position
    extern function void f_stmt();        // STATEMENT position, same call
    extern function void f_asg();         // assignment RHS, expression position
    extern function void f_case();        // CASE condition window
    extern function void f_assert();      // IMMEDIATE ASSERT condition window
    extern function void f_while();       // WHILE condition (no window)
    extern function void f_ret();         // RETURN operand
    // The NEIGHBOURS that share the window but not the road.
    extern function void n_bare();        // RECEIVER-LESS call in a condition
    extern function void n_builtin();     // BUILT-IN method arg in a condition
    extern function void n_sys();         // $cast argument in a condition
    extern function void n_plainref();    // a BARE ref in the condition
    extern function void n_stmt_bare();   // receiver-less call, STATEMENT
    extern function void n_bi_stmt();     // BUILT-IN method arg, STATEMENT, d0
    extern function void n_bi_cond();     // BUILT-IN method arg, CONDITION, d0
    // The CONTROLS: a RESOLVABLE local type in the identical positions.
    extern function void ct_cond();
    extern function void ct_stmt();
    // The IN-BODY twin of the face.
    function void ib_cond();
      T ibv;
      if (s.ask(ibv) == 0) w = 1;
    endfunction
  endclass

  function void c179::f_cond();
    T v;
    if (s.ask(v) == 0) w = 1;        // a01 THE FACE
  endfunction

  function void c179::f_stmt();
    T v;
    s.take(v);                       // a02 statement position
  endfunction

  function void c179::f_asg();
    T v;
    w = s.ask(v);                    // a03 assignment RHS
  endfunction

  function void c179::f_case();
    T v;
    case (s.ask(v))                  // a04 case condition
      0: w = 1;
      default: w = 2;
    endcase
  endfunction

  function void c179::f_assert();
    T v;
    assert (s.ask(v) == 0) w = 1;    // a05 immediate assert condition
  endfunction

  function void c179::f_while();
    T v;
    while (s.ask(v) == 99) w = 1;    // a06 while condition (no window)
  endfunction

  function void c179::f_ret();
    T v;
    w = s.ask(v) + 1;                // a07 operand of an operation
  endfunction

  function void c179::n_bare();
    T v;
    if (free179(v) == 0) w = 1;      // a10 receiver-less call, condition
  endfunction

  function void c179::n_builtin();
    T v;
    if (qv.size() == 0) qv.push_back(v);   // a11 BUILT-IN method arg
  endfunction

  function void c179::n_sys();
    T v;
    if ($cast(v, plain)) w = 1;      // a12 $cast argument in a condition
  endfunction

  function void c179::n_plainref();
    T v;
    if (v == null) w = 1;            // a13 a BARE ref in the condition
  endfunction

  function void c179::n_stmt_bare();
    T v;
    free179v(v);                     // a14 receiver-less call, statement
  endfunction

  function void c179::n_bi_stmt();
    T v;
    qv.push_back(v);                 // a15 BUILT-IN method arg, STATEMENT, d0
  endfunction

  function void c179::n_bi_cond();
    T v;
    if (amap.exists(v)) w = 1;       // a16 BUILT-IN method arg, CONDITION, d0
  endfunction

  function void c179::ct_cond();
    d179 v;
    if (s.ask(v) == 0) w = 1;        // a20 CONTROL: resolvable type, face position
  endfunction

  function void c179::ct_stmt();
    d179 v;
    s.take(v);                       // a21 CONTROL: resolvable type, statement
  endfunction

  function int  free179(d179 v); return 0; endfunction
  function void free179v(d179 v); endfunction

endpackage

module top179;
  import pa179::*;
  c179 #(d179) inst179;
  initial begin
    inst179 = new();
  end
endmodule
