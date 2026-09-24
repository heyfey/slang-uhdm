// r10uvm69repro/a2_scope.sv — THE SCOPE x TYPE GRID, all in STATEMENT position.
//
// a1_type proved the POSITION law (statement -> collapse, expression -> keep) on
// a package free function, for EVERY return type.  ONE corpus cell contradicts
// it: `index_string.itoa(index);` (uvm_printer.svh:992) is STATEMENT position
// and golden KEEPS the method shape.  Two candidates survive that cell:
//
//   (S) the enclosing routine is a class OUT-OF-BODY method
//       (`function string uvm_printer::index_string(...)`) — every corpus cell
//       that COLLAPSES is an IN-BODY method (open_recorder, create_item) or a
//       free/covergroup function (CrossFunc myFunc1);
//   (T) the return type is `string`.
//
// They are separated here by the two cells the corpus does not contain:
//   G2  string return, IN-BODY class method, statement   -> (S) collapse, (T) keep
//   H1  class-handle return, OUT-OF-BODY method, stmt    -> (S) keep, (T) collapse
//
// Every routine also gets an EXPRESSION-position twin so the position law is
// re-measured at each scope rather than assumed from a1.
package p2;

  class cH;
    int v;
    function void touch(int x); v = x; endfunction
    function int  peek();       return v; endfunction
  endclass

  class c2;
    // G1 — class handle, IN-BODY method, STATEMENT.  The HEAD's exact shape
    //      (uvm_tr_stream::open_recorder).
    function cH g_h_in(int n);
      g_h_in = new();
      g_h_in.touch(n);              // G1
    endfunction

    // G2 — string, IN-BODY method, STATEMENT.  THE DISCRIMINATING CELL.
    function string g_s_in(int n);
      g_s_in.itoa(n);               // G2
    endfunction

    // G3 — class handle, IN-BODY method, EXPRESSION (position control).
    function int g_h_in_e(int n);
      cH h;
      h = new();
      g_h_in_e = h.peek();          // G3 (ordinary local: CONTROL)
    endfunction

    function cH g_h_in_e2(int n);
      int k;
      g_h_in_e2 = new();
      k = g_h_in_e2.peek();         // G4 (return-name, EXPRESSION)
    endfunction

    // G5 — string, IN-BODY method, EXPRESSION.
    function string g_s_in_e(int p);
      g_s_in_e = "abcdef";
      g_s_in_e = g_s_in_e.substr(0, p);   // G5
    endfunction

    // declarations for the out-of-body bodies below
    extern function cH     h_h_out(int n);
    extern function string h_s_out(int n);
    extern function cH     h_h_out_e(int n);
    extern function string h_s_out_e(int p);
  endclass

  // H1 — class handle, OUT-OF-BODY method, STATEMENT.  THE OTHER
  //      DISCRIMINATING CELL.
  function cH c2::h_h_out(int n);
    h_h_out = new();
    h_h_out.touch(n);               // H1
  endfunction

  // H2 — string, OUT-OF-BODY method, STATEMENT.  The corpus twin of
  //      `index_string.itoa(index);` — golden KEEPS there.
  function string c2::h_s_out(int n);
    h_s_out.itoa(n);                // H2
  endfunction

  // H3 — class handle, OUT-OF-BODY, EXPRESSION.
  function cH c2::h_h_out_e(int n);
    int k;
    h_h_out_e = new();
    k = h_h_out_e.peek();           // H3
  endfunction

  // H4 — string, OUT-OF-BODY, EXPRESSION.
  function string c2::h_s_out_e(int p);
    h_s_out_e = "abcdef";
    h_s_out_e = h_s_out_e.substr(0, p);  // H4
  endfunction

  // J1/J2 — package FREE function twins of G1/G2, the a1 baseline repeated in
  //         the same database so the scope axis is read off ONE golden.
  function cH j_h_free(int n);
    j_h_free = new();
    j_h_free.touch(n);              // J1
  endfunction

  function string j_s_free(int n);
    j_s_free.itoa(n);               // J2
  endfunction

endpackage

module a2_top;
  import p2::*;

  // K1/K2 — MODULE-level function twins, statement position.
  function automatic cH k_h_mod(int n);
    k_h_mod = new();
    k_h_mod.touch(n);               // K1
  endfunction

  function automatic string k_s_mod(int n);
    k_s_mod.itoa(n);                // K2
  endfunction

  cH     h1;
  string s1;
  initial begin
    h1 = k_h_mod(3);
    s1 = k_s_mod(4);
  end
endmodule
