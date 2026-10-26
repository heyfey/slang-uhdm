// § unitParamNameBindsDesign431
localparam CF = 2;
module top(CF, y);
input CF;
output y;
assign y = CF;
endmodule
