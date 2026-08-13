// r10buvm2 ARM a3 ??? the OVER-FIRE controls.  Every carrier of a time literal /
// `null` / `$sysfunc` initializer that is NOT a class property.  A patch that
// only touches emitClassDefn + emitClassPropInit29 must leave every cell here
// byte-identical to the pristine binary; the arm exists so that claim is
// measured rather than asserted.
`timescale 1ns/1ps

package p3;
  parameter time P3_T = 5ns;      // package parameter
endpackage

module m3;
  import p3::*;
  parameter time n01_p = 5ns;     // module parameter
  localparam time n02_lp = 7us;   // module localparam
  time n03_mv = 5ns;              // MODULE-scope variable
  int  n04_mi = 5ns;
  logic n05_null_ctrl;

  typedef struct packed { logic [3:0] a; } st3_t;
  st3_t n06_st = '{a: 4'h5};

  function automatic int f3(input int x);
    time n07_lv = 5ns;            // FUNCTION-LOCAL variable
    int  n08_lr = $urandom;       // function-local system call
    f3 = x + int'(n07_lv) + n08_lr;
  endfunction

  initial begin
    #5ns;                         // a time literal in STATEMENT position
    n03_mv = 7ps;
  end
endmodule
