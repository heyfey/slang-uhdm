// § unitParamNameBindsDesign431 (a module function reading a module variable with the $unit name)
localparam CF = 2;
module top(input [3:0] c, output logic y);
logic CF;
assign CF = c[0];
function automatic logic f();
  return CF;
endfunction
always_comb y = f();
endmodule
