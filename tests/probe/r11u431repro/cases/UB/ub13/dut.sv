// § unitParamNameBindsDesign431
localparam CF = 2;
module top(input [3:0] c, output logic y);
if (1) begin : g
  localparam CF = 1;
  always_comb y = c[CF];
end
endmodule
