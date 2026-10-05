// § unitTdRetVarAtTypeToken245
// a module function returning a $unit vector typedef, its formal of the same type
typedef logic [3:0] nib_t;
module top(input logic [3:0] i, output logic [3:0] o);
  function automatic nib_t inc(nib_t a);
    return a + 1;
  endfunction
  assign o = inc(i);
endmodule
