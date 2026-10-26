// § unitParamNameBindsDesign431 (a program block)
localparam CF = 2;
program prg(input [3:0] c, output logic y);
localparam CF = 1;
initial y = c[CF];
endprogram
module top(input [3:0] c, output y);
prg p(.c(c), .y(y));
endmodule
