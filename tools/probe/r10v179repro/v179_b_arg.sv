// r10v179 ADVERSARIAL ARM B — ARGUMENT KINDS x DEPTHS x POSITION PAIRS.
// The axes r10uvm179's arm C left short: a PACKAGE VARIABLE argument, a
// PACKAGE PARAMETER argument, a SHADOWED name (local whose name is also a
// package variable / package parameter — residue R4's shape, both directions),
// the SAME CALL AT TWO DEPTHS IN ONE SUBROUTINE (the pair is its own cell),
// depth 3, and an argument that is itself a nested RECEIVER-LESS call's arg.
// MEASUREMENT ONLY.
package pkg_yank;

  parameter int SHARED_P = 7;
  int           shared_v;
  int           dup_name;      // shadowed by a local in y40/y41

  class Cog;
    int spin;
  endclass

  class Rack;
    function int  look(Cog c); return 0; endfunction
    function int  look2(Cog a, Cog b); return 0; endfunction
    function int  looki(int k); return k; endfunction
    function void put(Cog c); endfunction
  endclass

  class Frame #(type PART = Cog);
    Rack rk;
    Cog  own_part;      // a class PROPERTY of the argument's type
    int  scoreboardz;

    extern function void y00();                 // depth 0, the moving cell
    extern function void y01();                 // depth 1
    extern function void y03();                 // depth 3
    extern function void y_pair();              // SAME call at depth 0 AND 2
    extern function void y_formal(PART fm);     // a FORMAL argument
    extern function void y_prop();              // a class PROPERTY argument
    extern function void y_pkgvar();            // a PACKAGE VARIABLE argument
    extern function void y_pkgparm();           // a PACKAGE PARAMETER argument
    extern function void y_lit();               // a LITERAL argument
    extern function void y_shadow_v();          // local NAME == package VARIABLE
    extern function void y_shadow_p();          // local NAME == package PARAMETER
    extern function void y_nested_free();       // rk.look(...) wrapping free(loc)
    extern function void y_two();               // TWO ref_var arguments
    extern function void y_blocklocal();        // declared IN the block at depth 1
  endclass

  function void Frame::y00();
    PART loc;
    if (rk.look(loc) == 0) scoreboardz = 1;                 // y00
  endfunction

  function void Frame::y01();
    PART loc;
    if (scoreboardz == 0) begin
      if (rk.look(loc) == 0) scoreboardz = 2;               // y01 depth 1
    end
  endfunction

  function void Frame::y03();
    PART loc;
    if (scoreboardz == 0) begin
      if (scoreboardz == 1) begin
        if (scoreboardz == 2) begin
          if (rk.look(loc) == 0) scoreboardz = 3;           // y03 depth 3
        end
      end
    end
  endfunction

  // THE PAIR: one subroutine, one local, the SAME call written twice at two
  // different control-body depths.  Golden must answer both, and our two
  // answers must match golden's two answers cell by cell.
  function void Frame::y_pair();
    PART twin;
    if (rk.look(twin) == 0) scoreboardz = 4;                // y_pair d0
    if (scoreboardz == 4) begin
      if (scoreboardz == 4) begin
        if (rk.look(twin) == 1) scoreboardz = 5;            // y_pair d2
      end
    end
  endfunction

  function void Frame::y_formal(PART fm);
    if (rk.look(fm) == 0) scoreboardz = 6;                  // y_formal
  endfunction

  function void Frame::y_prop();
    if (rk.look(own_part) == 0) scoreboardz = 7;            // y_prop
  endfunction

  function void Frame::y_pkgvar();
    if (rk.looki(shared_v) == 0) scoreboardz = 8;           // y_pkgvar
  endfunction

  function void Frame::y_pkgparm();
    if (rk.looki(SHARED_P) == 0) scoreboardz = 9;           // y_pkgparm
  endfunction

  function void Frame::y_lit();
    if (rk.looki(33) == 0) scoreboardz = 10;                // y_lit
  endfunction

  // A local whose NAME is also a package VARIABLE.  Surelog's lateBinding
  // function/task arm has no early exit, so the package listing is the LAST
  // writer: golden is expected to bind the PACKAGE variable here.
  function void Frame::y_shadow_v();
    PART dup_name;
    if (rk.look(dup_name) == 0) scoreboardz = 11;           // y_shadow_v
  endfunction

  // A local whose NAME is also a package PARAMETER.
  function void Frame::y_shadow_p();
    PART SHARED_P;
    if (rk.look(SHARED_P) == 0) scoreboardz = 12;           // y_shadow_p
  endfunction

  function void Frame::y_nested_free();
    PART loc;
    if (rk.look(loose_pass(loc)) == 0) scoreboardz = 13;    // y_nested_free
  endfunction

  function void Frame::y_two();
    PART one;
    PART two;
    if (rk.look2(one, two) == 0) scoreboardz = 14;          // y_two
  endfunction

  function void Frame::y_blocklocal();
    if (scoreboardz == 0) begin
      PART inner;
      if (rk.look(inner) == 0) scoreboardz = 15;            // y_blocklocal
    end
  endfunction

  function Cog loose_pass(Cog c); return c; endfunction

endpackage

module tb_yank;
  import pkg_yank::*;
  Frame #(Cog) f_a;
  Frame #(Cog) f_b;
  Frame #(Cog) f_c;
  initial begin
    f_a = new();
    f_b = new();
    f_c = new();
  end
endmodule
