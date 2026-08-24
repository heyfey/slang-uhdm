// vb32h1 — HOMES: $unit class, module-declared class, interface, program,
// generate block, always block, plus chained calls and a shadowing local.
class u32;                      // $unit-scope class
  typedef u32 this_type;
  static int uh32;
  extern static function int uf32(int a);
  static function int uinb32(int a); return a; endfunction
endclass
function int u32::uf32(int a); uh32 += a; return a; endfunction

class chain32;
  typedef chain32 this_type;
  extern static function chain32 mk32(int a);
  function int nx32(int a); return a; endfunction
endclass
function chain32 chain32::mk32(int a); chain32 c = new(); return c; endfunction

module vb32h1;
  int r;
  class m32;                    // class declared INSIDE a module
    typedef m32 this_type;
    static int mh32;
    extern static function int mf32(int a);
  endclass
  function int m32::mf32(int a); mh32 += a; return a; endfunction

  initial begin
    r  = u32::uf32(1);          // H1  $unit class, own name        -> call
    r += u32::this_type::uf32(2);// H2 three segments via this_type  -> ?
    r += this_u32();            // H3  helper
    r += m32::mf32(4);          // H4  module class, own name       -> call
    r += m32::this_type::mf32(5); // H5 module class via this_type      -> ref
    r += chain32::mk32(6).nx32(7); // H6 chained C::m().n()
  end
  function int this_u32(); return u32::uinb32(3); endfunction  // H3 in-body callee -> ref

  always @(*) begin
    r = u32::uf32(8);           // H8 always home
  end

  for (genvar g32 = 0; g32 < 2; g32++) begin : gb32
    int gr32;
    initial gr32 = u32::uf32(9 + g32);   // H9 generate home
  end
endmodule

interface if32;
  int ir32;
  initial ir32 = u32::uf32(10);          // H10 interface home
endinterface

program pg32;
  int pr32;
  initial pr32 = u32::uf32(11);          // H11 program home
endprogram
