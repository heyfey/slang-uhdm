// § unitParamNameBindsDesign431 (a generate-if condition and a generate-for bound)
localparam CF = 2;
module top(input [3:0] c, output logic [3:0] y);
localparam CF = 1;
if (CF > 0) begin : g
  assign y[0] = c[0];
end
for (genvar i = 0; i < CF; i++) begin : l
  assign y[i+1] = c[i];
end
endmodule
