// r10buvm32repro/g32a1.sv — the WRITTEN-QUALIFIER grid for a `::`-scoped call.
// Every cell varies ONE thing: the spelling of the qualifier (own class name /
// a typedef alias of the own class / `this_type` / a BASE class name / a
// package-qualified class) against a callee that is defined OUT-OF-BODY or
// IN-BODY, at three call HOMES (out-of-body method, in-body method, package
// function) and four POSITIONS (statement, assignment-Rhs, if-condition,
// argument).
package p32;

  class base32;
    static int bhits32;
    extern static function void bv32(int a);
    extern static function int  bf32(int a);
    static function void binb32(int a); bhits32 += a; endfunction
  endclass
  function void base32::bv32(int a); bhits32 += a; endfunction
  function int  base32::bf32(int a); return a * 2; endfunction

  class der32 extends base32;
    typedef der32 this_type;
    typedef der32 alias32;
    extern static function void dv32(int a);
    extern static function int  df32(int a);
    static function void dinb32(int a); bhits32 += a; endfunction
    static function int  dinbf32(int a); return a + 1; endfunction
    extern static function void oob32();
    function void inb32();
      int r;
      der32::dv32(40);            // B1  own name  / out-of-body callee
      this_type::dv32(41);        // B2  this_type / out-of-body callee
      alias32::dv32(42);          // B3  alias     / out-of-body callee
      base32::bv32(43);           // B4  base name / out-of-body callee
      der32::dinb32(44);          // B5  own name  / IN-BODY callee
      r = this_type::df32(45);    // B6  assignment Rhs
      if (der32::df32(46)) r = 1; // B7  if-condition
      $display("%0d", this_type::df32(47) + r);  // B8 argument position
    endfunction
  endclass
  function void der32::dv32(int a); bhits32 += a; endfunction
  function int  der32::df32(int a); return a + 3; endfunction

  function void der32::oob32();
    int r;
    der32::dv32(1);             // A1  own name  / out-of-body callee
    this_type::dv32(2);         // A2  this_type / out-of-body callee  <= THE HEAD SHAPE
    alias32::dv32(3);           // A3  alias     / out-of-body callee
    base32::bv32(4);            // A4  base name / out-of-body callee
    der32::bv32(5);             // A5  DERIVED name / callee out-of-body in the BASE
    der32::dinb32(6);           // A6  own name  / IN-BODY callee
    this_type::dinb32(7);       // A7  this_type / IN-BODY callee
    r = der32::df32(8);         // A8  assignment Rhs, own name
    r = this_type::df32(9);     // A9  assignment Rhs, this_type
    if (der32::df32(10)) r = 1;      // A10 if-condition, own name
    if (this_type::df32(11)) r = 2;  // A11 if-condition, this_type
    $display("%0d", der32::df32(12));      // A12 argument, own name
    $display("%0d", this_type::df32(13));  // A13 argument, this_type
    $display("%0d", der32::dinbf32(14));   // A14 argument, IN-BODY callee
    r = base32::bf32(15) + r;   // A15 assignment Rhs, base name
  endfunction

  // PACKAGE-FUNCTION home: the qualifier can only be a class name here.
  function void pkgrun32();
    int r;
    der32::dv32(21);            // P1
    base32::bv32(22);           // P2
    der32::dinb32(23);          // P3 IN-BODY callee
    r = der32::df32(24);        // P4
    $display("%0d", r);
  endfunction
endpackage

module g32a1;
  import p32::*;
  int r;
  initial begin
    p32::der32::dv32(31);       // M1  pkg::Class::method, out-of-body callee
    p32::base32::bv32(32);      // M2
    der32::dv32(33);            // M3  wildcard-imported class name
    p32::pkgrun32();            // M4  the package-function CONTROL: stays a func_call
    r = p32::der32::df32(34);   // M5  pkg::Class::method in Rhs
    $display("%0d", r);
  end
endmodule
