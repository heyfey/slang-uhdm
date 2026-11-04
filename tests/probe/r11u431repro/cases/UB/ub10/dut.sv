// § unitParamNameBindsDesign431
localparam CF = 2;
module top(input [3:0] c, output logic y);
localparam CF = 1;
function automatic logic f(input [3:0] a);
  return a[CF];
endfunction
always_comb y = f(c);
endmodule
