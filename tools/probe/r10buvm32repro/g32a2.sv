// r10buvm32repro/g32a2.sv — the PARAMETERIZED-class half of the grid (UVM's own
// shape: `typedef cls#(T) this_type;` inside a generic class, called through
// `this_type::` from an out-of-body body) plus the `pkg::Class::` spelling at
// every home, a NON-CONSTANT argument (does golden drop it too?), and the
// resolvable controls.
package q32;

  class gen32 #(type T = int, int W = 1);
    typedef gen32 #(T, W) this_type;
    static int ghits32;
    extern static function void gv32(int a);
    extern static function int  gf32(int a);
    static function void ginb32(int a); ghits32 += a; endfunction
    extern static function void grun32(int seed);
    extern function void gmeth32(int seed);
  endclass

  function void gen32::gv32(int a); ghits32 += a; endfunction
  function int  gen32::gf32(int a); return a + W; endfunction

  function void gen32::grun32(int seed);
    int r;
    this_type::gv32(seed);        // G1  this_type:: with a NON-CONSTANT argument
    gen32::gv32(seed);            // G2  own (unparameterized) name
    this_type::ginb32(seed);      // G3  this_type:: / IN-BODY callee
    gen32::ginb32(seed);          // G4  own name / IN-BODY callee
    r = this_type::gf32(seed);    // G5  Rhs
    r = gen32::gf32(seed);        // G6  Rhs, own name
    if (this_type::gf32(seed)) r = 1;  // G7 if-condition
    $display("%0d", gen32::gf32(seed) + r);  // G8 argument
  endfunction

  function void gen32::gmeth32(int seed);
    this_type::gv32(seed);        // G9  IN-BODY home
    gen32::gv32(seed);            // G10
  endfunction

  class host32;
    extern static function void hv32(int a);
    static function void hinb32(int a); endfunction
  endclass
  function void host32::hv32(int a); gen32#(int,1)::gv32(a); endfunction  // G11 explicit specialization spelling

  function void qrun32(int seed);
    int r;
    gen32#(int,1)::gv32(seed);    // Q1  explicit `#()` spelling / out-of-body callee
    gen32#(int,1)::ginb32(seed);  // Q2  explicit `#()` spelling / IN-BODY callee
    host32::hv32(seed);           // Q3  plain class name / out-of-body callee (control: keeps the call)
    host32::hinb32(seed);         // Q4  plain class name / IN-BODY callee
    r = gen32#(int,1)::gf32(seed);// Q5
    $display("%0d", r);
  endfunction
endpackage

module g32a2;
  int s = 3;
  int r;
  initial begin
    q32::host32::hv32(s);        // N1  pkg::Class:: / out-of-body callee
    q32::host32::hinb32(s);      // N2  pkg::Class:: / IN-BODY callee
    q32::qrun32(s);              // N3  package free function CONTROL
    r = q32::gen32#(int,1)::gf32(s);  // N4 pkg::Class#()::method
    $display("%0d", r);
  end
endmodule
