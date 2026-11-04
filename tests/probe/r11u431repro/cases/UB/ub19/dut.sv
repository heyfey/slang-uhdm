// § unitParamNameBindsDesign431
localparam CF = 2;
module top(input [3:0] c, output logic y);
logic CF;
always_comb begin
  CF = c[1];
  y = CF;
end
endmodule
