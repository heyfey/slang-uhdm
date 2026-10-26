// § unitParamNameBindsDesign431 (a $unit parameter shadowed by a localparam used in a packed range)
localparam W = 2;
module top(input [7:0] c, output logic [3:0] y);
localparam W = 4;
logic [W-1:0] t;
assign t = c[W-1:0];
always_comb y = t;
endmodule
