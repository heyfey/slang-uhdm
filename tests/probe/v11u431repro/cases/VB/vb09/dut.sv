// § unitParamNameBindsDesign431 (a function argument named like the $unit parameter)
localparam CF = 2;
module top(input [3:0] c, output logic y);
function automatic logic f(input [3:0] CF);
  return CF[1];
endfunction
always_comb y = f(c);
endmodule
