// § unitParamNameBindsDesign431 (a named begin declaring another variable)
localparam CF = 2;
module top(input [3:0] c, output logic y);
localparam CF = 1;
always_comb begin : b
  logic t;
  t = c[CF];
  y = t;
end
endmodule
