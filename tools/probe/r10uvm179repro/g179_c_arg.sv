// r10uvm179 arm C — THE ARGUMENT KINDS × THE CONTROL-BODY DEPTHS, one golden.
// MEASUREMENT ONLY.  Every cell is the FACE receiver shape (a one-name class
// property, `s.ask(...)`) standing in EXPRESSION position; what varies is WHAT
// is passed and HOW DEEP the call sits.
//
// The point of the depth column: § refVarLocalWindowBinds5 binds a `ref_var`
// local only at the depth its declaration was read at, so a naive "the window
// is closed here" law and a "depth" law would agree at depth 0 and part
// company at depth 1+.  The point of the KIND column: a FORMAL (`io_decl`), a
// class PROPERTY, a LITERAL and a RESOLVED local are NOT `ref_var`s, and
// Surelog's late binder skips only the `ref_var`.
package pc179;

  class d179c;
    int fld;
  endclass

  class sink179c;
    function int ask(d179c v); return 0; endfunction
    function int askn(int k); return k; endfunction
    function int ask2(d179c v, int k); return k; endfunction
  endclass

  class c179c #(type T = d179c);
    sink179c s;
    d179c    prop;          // a class PROPERTY of the argument type
    int      iprop;
    int      w;

    extern function void k_local(T f);      // depths 0/1/2 with the ref_var local
    extern function void k_formal(T f);     // the FORMAL as the argument
    extern function void k_prop();          // a class PROPERTY as the argument
    extern function void k_lit();           // a LITERAL as the argument
    extern function void k_resolved();      // a RESOLVED local (not a ref_var)
    extern function void k_oper();          // the ref_var inside an OPERATION
    extern function void k_nested();        // the ref_var inside a NESTED call
    extern function void k_two();           // two arguments, mixed kinds
    extern function void k_blk1();          // a ref_var declared IN the block
  endclass

  function void c179c::k_local(T f);
    T v;
    if (s.ask(v) == 0) w = 1;                    // c00 depth 0  — THE FACE
    if (prop != null) begin
      if (s.ask(v) == 0) w = 2;                  // c01 depth 1
      if (iprop == 3) begin
        if (s.ask(v) == 0) w = 3;                // c02 depth 2
      end
    end
  endfunction

  function void c179c::k_formal(T f);
    if (s.ask(f) == 0) w = 1;                    // c10 a FORMAL, depth 0
    if (prop != null) begin
      if (s.ask(f) == 0) w = 2;                  // c11 a FORMAL, depth 1
    end
  endfunction

  function void c179c::k_prop();
    if (s.ask(prop) == 0) w = 1;                 // c20 a class PROPERTY, depth 0
  endfunction

  function void c179c::k_lit();
    if (s.askn(7) == 0) w = 1;                   // c30 a LITERAL, depth 0
  endfunction

  function void c179c::k_resolved();
    d179c v;
    if (s.ask(v) == 0) w = 1;                    // c40 a RESOLVED local, depth 0
    if (prop != null) begin
      if (s.ask(v) == 0) w = 2;                  // c41 a RESOLVED local, depth 1
    end
  endfunction

  function void c179c::k_oper();
    T v;
    if (s.askn((v == null) ? 1 : 0) == 0) w = 1; // c50 inside an OPERATION
  endfunction

  function void c179c::k_nested();
    T v;
    if (s.askn(s.ask(v)) == 0) w = 1;            // c60 inside a NESTED call
  endfunction

  function void c179c::k_two();
    T v;
    if (s.ask2(v, iprop) == 0) w = 1;            // c70/c71 two arguments
  endfunction

  function void c179c::k_blk1();
    if (prop != null) begin
      T bv;
      if (s.ask(bv) == 0) w = 1;                 // c80 declared IN the block, d1==d1
    end
  endfunction

endpackage

module top179c;
  import pc179::*;
  c179c #(d179c) instc;
  initial begin
    instc = new();
  end
endmodule
