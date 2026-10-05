// § unitPredefTd245
// $unit typedefs written in an included header, used by a module variable and a function
`include "defs.svh"
module top(input logic [5:0] i, output int unsigned o, output logic [5:0] p);
  function automatic cnt_t widen(six_t v);
    return v;
  endfunction
  six_t r;
  assign r = i;
  assign p = r;
  assign o = widen(r);
endmodule
