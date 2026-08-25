// r10uvm150 arm A — RECEIVER SHAPES for a call chain.
// Deliberately UNPARALLEL names/orders/numbers so an agreeing cell is not a
// self-confirming one.
package pk_zeta;

  class Handle7;
    int fld9 = 41;
    function int rd(int k); return k + fld9; endfunction
    task    tk(int k); fld9 = k; endtask
    function void vd(int k); fld9 = k + 1; endfunction
  endclass

  // OUT-OF-BODY static getter: getTaskFunc registers "Maker3::mk" ->
  // Surelog keeps the func_call.
  class Maker3;
    extern static function Handle7 mk();
    static function Handle7 inb();          // IN-BODY static: degrades to ref_obj
      Handle7 h = new(); return h;
    endfunction
  endclass
  function Handle7 Maker3::mk();
    Handle7 h = new(); return h;
  endfunction

  // A PACKAGE free function returning a handle.
  function Handle7 pkmk(int q);
    Handle7 h = new(); h.fld9 = q; return h;
  endfunction

  class Driver5;
    Handle7 memb;
    Handle7 arr[4];
    function new(); memb = new(); endfunction

    function int c01();                       // A1  out-of-body scoped call . function(1 arg)
      return Maker3::mk().rd(7);
    endfunction
    function int c02();                       // A2  in-body scoped call . function(1 arg)
      return Maker3::inb().rd(8);
    endfunction
    function int c03();                       // A3  package free call . function(1 arg)
      return pkmk(3).rd(9);
    endfunction
    function int c04();                       // A4  plain VARIABLE receiver (control)
      return memb.rd(10);
    endfunction
    function int c05();                       // A5  INDEXED variable receiver (control)
      return arr[2].rd(11);
    endfunction
    task c06();                               // A6  scoped call . TASK, statement position
      Maker3::mk().tk(12);
    endtask
    task c07();                               // A7  scoped call . VOID function, statement
      Maker3::mk().vd(13);
    endtask
    function int c08();                       // A8  scoped call . PROPERTY (no call at all)
      return Maker3::mk().fld9;
    endfunction
    function int c09();                       // A9  three-deep chain
      return Maker3::mk().rd(Maker3::mk().rd(2));
    endfunction
    function int c10();                       // A10 scoped call, ZERO-arg method
      return Maker3::mk().rd(0);
    endfunction
    function int c11();                       // A11 chain inside an IF condition
      if (Maker3::mk().rd(5) > 3) return 1; else return 0;
    endfunction
    function int c12();                       // A12 chain as a CALL ARGUMENT
      return rdwrap(Maker3::mk().rd(6));
    endfunction
    function int rdwrap(int z); return z; endfunction
    function int c13();                       // A13 scoped call with ARGUMENTS then chain
      return pkmk(4).rd(14);
    endfunction
  endclass
endpackage

module topA;
  import pk_zeta::*;
  Driver5 d;
  int r1, r2;
  initial begin
    d = new();
    r1 = d.c01();
    r2 = d.c02();
    d.c06();
  end
endmodule
