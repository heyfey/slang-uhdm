// § pkgDupSignalLeftoverNet451
package a; typedef reg [3:0] r_t; typedef logic [1:0] l_t; r_t vr; l_t vl; reg [1:0] rr; bit [1:0] bb; endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; endpackage
module top; endmodule
