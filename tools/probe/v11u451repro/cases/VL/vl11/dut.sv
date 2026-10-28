// § leftNetInitEnd451v
`define INIT 7
package a; typedef logic [3:0] n_t; n_t tv = 4'h1; logic [1:0][3:0] pm = '0; int mv = `INIT; var vi2 = 1'b0; logic [2:0] un [2] = '{3'd1, 3'd2}; endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; endpackage
module top; endmodule
