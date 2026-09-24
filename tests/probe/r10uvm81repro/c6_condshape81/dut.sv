// r10uvm81 arm c6 — the THIRD cut.  Arm c5 says an `if` CONDITION and a `case`
// EXPRESSION keep the formal while every other position takes the package
// variable; BuildUVMPkg's `if ((cs != actual) && (cs != null))` takes the
// PACKAGE VARIABLE and is an if condition, so the condition alone cannot be the
// discriminator.  This arm varies the SHAPE of the condition at fixed position.
package p86;
  int    sink;
  class c86;
    string m_s;
    extern function new();
  endclass
  function c86::new();
    begin
      string val;
      val = "x";
      m_s = val;
    end
  endfunction
  function int fh86(int a); return a; endfunction

  function int g86(int val);
    if (val)                       sink = 1;   // E1  BARE ref as the condition
    if (val == 0)                  sink = 2;   // E2  depth-1 operation
    if ((val == 0) && (val == 1))  sink = 3;   // E3  depth-2 operation (BuildUVMPkg's shape)
    if (!val)                      sink = 4;   // E4  unary
    if (fh86(val) == 0)            sink = 5;   // E5  under a call
    if (val == 0) begin sink = 6; end          // E6  depth-1, begin body
    if ((val != 0) || (val != 1))  sink = 7;   // E7  depth-2, other operators
    case (val)         0: sink = 8;  default: sink = 9;  endcase  // E8  bare case expr
    case (val + 1)     0: sink = 10; default: sink = 11; endcase  // E9  depth-1 case expr
    case ((val+1)*2)   0: sink = 12; default: sink = 13; endcase  // E10 depth-2 case expr
    if (val == 0) sink = 14; else sink = 15;   // E11 if/ELSE, depth-1
    return val;                                 // E12 control (must take the pkg var)
  endfunction
endpackage
