// § unitParamNameBindsDesign431
localparam CF = 2;
module top(input [3:0] c, output logic y);
always_comb begin : b
  logic CF;
  CF = c[1];
  y = CF;
end
endmodule
