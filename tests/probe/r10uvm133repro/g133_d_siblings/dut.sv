// r10uvm133 arm D - the SIBLING type-query system functions over the SAME
// argument kinds, incl. a call.  The law is $bits-only; this arm is the
// control that proves the siblings do not move.  MEASUREMENT ONLY.
package p133_d;
  class sib133_c;
    int         dq[$];
    bit [15:0]  dv;
    bit [7:0]   da [4];
    bit [3:0][7:0] dm;

    function int df133(); return 4; endfunction

    function void probe133();
      int r;
      r = $bits(dv);                 // D01 control: $bits over a name
      r = $bits(df133());            // D02 $bits over a call   <- the law
      r = $size(dq);                 // D03 $size over a name
      r = $size(da);                 // D04 $size over an array
      r = $size(dm, 1);              // D05 $size with a dim index
      r = $size(df133());            // D06 $size over a call
      r = $clog2(16);                // D07 $clog2 over a literal
      r = $clog2(df133());           // D08 $clog2 over a call
      r = $high(da);                 // D09 $high over an array
      r = $high(df133());            // D10 $high over a call
      r = $low(da);                  // D11 $low over an array
      r = $low(df133());             // D12 $low over a call
      r = $left(dv);                 // D13 $left over a name
      r = $left(df133());            // D14 $left over a call
      r = $right(dv);                // D15 $right over a name
      r = $right(df133());           // D16 $right over a call
      r = $dimensions(dm);           // D17 $dimensions
      r = $increment(dv);            // D18 $increment
      if (r == 0) r = 1;
    endfunction
  endclass
endpackage
