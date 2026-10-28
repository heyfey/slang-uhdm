// § leftNetInitEnd451v
package a; int x1, x2 = 3; logic [1:0] y1 = 2'b01, y2; endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; endpackage
module top; endmodule
