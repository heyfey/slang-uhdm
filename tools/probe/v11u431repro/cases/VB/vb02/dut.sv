// § unitParamNameBindsDesign431 (a for-loop variable with the $unit name; parent scope a block)
localparam CF = 2;
module top(input [3:0] c, output logic y);
always_comb begin
  y = 0;
  for (int CF = 0; CF < 4; CF++) y = y ^ c[CF];
end
endmodule
