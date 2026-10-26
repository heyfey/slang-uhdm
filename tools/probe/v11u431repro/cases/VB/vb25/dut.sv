// § unitParamNameBindsDesign431 (a generate-for body reading the shadowing localparam)
localparam CF = 2;
module top(input [3:0] c, output logic [1:0] y);
localparam CF = 1;
for (genvar i = 0; i < 2; i++) begin : g
  assign y[i] = c[CF];
end
endmodule
