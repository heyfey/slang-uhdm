// § unitParamNameBindsDesign431
localparam CF = 2;
module top(input [3:0] c, output logic y, output logic z);
localparam CF = 1;
always_comb begin
  y = CF;
  z = c[CF + 1];
end
endmodule
