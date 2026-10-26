// § errTypePortSyntaxRange440
package pk; typedef enum logic [2:0] {P, W, E, N, S} dir_e; endpackage
module m import pk::*; #(parameter x = "inv", y = "inv") (input [y-1:0][x-1:0][S:W][1:0] a, output [E:W][y-1:0] b);
endmodule
module top; endmodule
