// § unitParamNameBindsDesign431 (a module localparam initializer reading the shadowing local)
localparam CF = 2;
module top(input [3:0] c, output logic y);
localparam CF = 1;
localparam Y = CF + 1;
always_comb y = c[Y];
endmodule
