// vb32m1 — the WIDE shape matrix demanded of the verifier: every scoped-call
// spelling x every position x several homes, with the task/function halves and
// the negative controls beside them.
package q32;
  function int qfree32(int a); return a + 1; endfunction

  class base32;
    static int hits32;
    extern static function void bv32(int a);
    extern static function int  bf32(int a);
    extern static task         bt32(int a);
    static function void binb32(int a); hits32 += a; endfunction
    static function int  binbf32(int a); return a; endfunction
  endclass
  function void base32::bv32(int a); hits32 += a; endfunction
  function int  base32::bf32(int a); return a * 2; endfunction
  task base32::bt32(int a); hits32 += a; endtask

  class der32 extends base32;
    typedef der32 this_type;
    typedef der32 alias32;
    typedef base32 balias32;
    extern static function void dv32(int a);
    extern static function int  df32(int a);
    extern static task          dt32(int a);
    static function int  dinbf32(int a); return a + 1; endfunction
    extern static function void oob32(output int o);
    extern static task toob32();
  endclass
  function void der32::dv32(int a); hits32 += a; endfunction
  function int  der32::df32(int a); return a + 3; endfunction
  task der32::dt32(int a); hits32 += a; endtask

  class gen32 #(type T = int, int W = 1);
    typedef gen32 #(T, W) this_type;
    static int ghits32;
    extern static function int gf32(int a);
    static function int ginbf32(int a); return a; endfunction
  endclass
  function int gen32::gf32(int a); return a + W; endfunction

  // a class holding a method whose name collides with the package free fn
  class coll32;
    extern static function int qfree32(int a);
  endclass
  function int coll32::qfree32(int a); return a - 1; endfunction

  task der32::toob32();
    // --- TASK half (task home: a task CAN call tasks) ---
    der32::dt32(8);              // W8  own name, out-of-body task -> call
    this_type::dt32(9);          // W9                             -> ref
    base32::bt32(10);            // W10                            -> call
    der32::bt32(11);             // W11                            -> ref
  endtask

  function void der32::oob32(output int o);
    int r; logic [7:0] v; int arr32 [3];
    // --- statement position, every qualifier spelling ---
    der32::dv32(1);              // W1  own name, out-of-body      -> call
    this_type::dv32(2);          // W2  this_type                  -> ref
    alias32::dv32(3);            // W3  typedef alias of own class -> ref
    base32::bv32(4);             // W4  defining base name         -> call
    der32::bv32(5);              // W5  derived name / base callee -> ref
    balias32::bv32(6);           // W6  typedef alias of the base  -> ref
    q32::der32::dv32(7);         // W7  pkg::Class::               -> ref
    // --- expression positions ---
    r = der32::df32(12);         // W12 Rhs, own name
    r = this_type::df32(13);     // W13 Rhs, this_type
    if (der32::df32(14)) r = 1;  // W14 if-cond own
    if (this_type::df32(15)) r = 2; // W15 if-cond this_type
    while (der32::df32(16) < 0) r = 3;      // W16 while-cond own
    while (this_type::df32(17) < 0) r = 4;  // W17 while-cond this_type
    $display("%0d", der32::df32(18));       // W18 argument own
    $display("%0d", this_type::df32(19));   // W19 argument this_type
    v = {der32::df32(20), this_type::df32(21)};  // W20/W21 concat members
    void'(der32::df32(22));                 // W22 void cast own
    void'(this_type::df32(23));             // W23 void cast this_type
    arr32[0] = der32::df32(24);             // W24 element Rhs
    arr32[1] = this_type::df32(25);         // W25
    // --- no-argument forms ---
    r = der32::df32(0) + this_type::df32(0);// W26/W27
    // --- generic class ---
    r = gen32#(int,1)::gf32(28);            // W28 parameter list written -> call
    r = gen32#(byte,2)::gf32(29);           // W29 a SECOND specialization -> call
    r = q32::gen32#(int,1)::gf32(30);       // W30 pkg::gen#()::          -> ref
    r = gen32#(int,1)::ginbf32(31);         // W31 in-body callee         -> ref
    // --- the package-free-function collision, class qualifier ---
    r = coll32::qfree32(32);                // W32 f12 == defining class  -> call
    r = q32::coll32::qfree32(33);           // W33 f12 == package WITH a free qfree32 -> ?
    r = q32::qfree32(34);                   // W34 CONTROL package free function
    // --- in-body / implicit / this. / super. controls ---
    r = der32::dinbf32(35);                 // W35 in-body callee -> ref
    r = base32::binbf32(36);                // W36 in-body callee -> ref
    o = r;
  endfunction

  // return-operand home
  function int retrun32();
    return der32::df32(40) + this_type_ref32();
  endfunction
  function int this_type_ref32(); return 0; endfunction
endpackage

module vb32m1;
  import q32::*;
  int r; int o;
  q32::der32 h32;
  initial begin
    q32::der32::oob32(o);
    q32::der32::toob32();
    r = q32::retrun32();
    der32::dv32(50);            // U1 wildcard-imported class name -> call
    q32::der32::dv32(51);       // U2 pkg::Class::                 -> ref
    $display("%0d %0d", r, o);
  end
  // continuous-assign / port-actual homes
  wire [31:0] w32;
  assign w32 = q32::der32::df32(60);        // U3 cont_assign Rhs
  sub32 i32 (.p32(q32::der32::df32(61)));   // U4 port actual
endmodule

module sub32(input int p32);
  int s32;
  initial s32 = p32;
endmodule
