// r10v150 arm A — HOMES the implementer's grid never visited:
// a $unit-scope class, an INTERFACE, a PROGRAM, a class declared INSIDE a
// module, plus ternary / case / always_comb contexts.
// Naming style, numbers and ordering deliberately unlike g150_*.
class Cell_A;
  int q = 7;
  function int add(int n); return q + n; endfunction
  task poke(int n); q = n; endtask
  function void bump(int n); q = n + 1; endfunction
endclass

class UMk;                                  // $unit-scope class
  extern static function Cell_A um();
  static function Cell_A ib();  Cell_A c = new(); return c; endfunction
endclass
function Cell_A UMk::um(); Cell_A c = new(); return c; endfunction

function Cell_A ufree(int z); Cell_A c = new(); c.q = z; return c; endfunction

interface IfcV;
  int wI, wJ;
  function int i1(); return UMk::um().add(31); endfunction   // scoped root, IFC home
  function int i2(); return ufree(32).add(33); endfunction   // bare  root, IFC home
  function int i3(); return UMk::ib().add(34); endfunction   // in-body static (ref_obj degrade)
  initial begin wI = i1() + i2(); wJ = i3(); end
endinterface

program PrgV;
  int wP, wQ;
  function int p1(); return UMk::um().add(41); endfunction   // scoped root, PROGRAM home
  task    p2();     UMk::um().poke(42);        endtask       // task method, statement
  function int p3(); return ufree(43).add(44); endfunction   // bare root, PROGRAM home
  initial begin wP = p1(); p2(); wQ = p3(); end
endprogram

module topV;
  class InMod;                               // a class declared INSIDE a module
    function int m1(); return UMk::um().add(51); endfunction
    function int m2(); return ufree(52).add(53); endfunction
    task         m3(); UMk::um().bump(54);       endtask
  endclass
  InMod im;
  int r1, r2, r3, r4, cw;
  IfcV u_ifc();
  PrgV u_prg();
  // TERNARY condition AND both branches
  function int t1();
    return (UMk::um().add(61) > 3) ? UMk::um().add(62) : ufree(63).add(64);
  endfunction
  // CASE selector
  function int t2();
    case (UMk::um().add(71))
      1: return 1;
      default: return 0;
    endcase
  endfunction
  always_comb cw = UMk::um().add(81);
  initial begin
    im = new();
    r1 = im.m1(); r2 = im.m2(); im.m3();
    r3 = t1(); r4 = t2();
  end
endmodule
