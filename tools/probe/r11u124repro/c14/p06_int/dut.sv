// § pkgQualFoldSpanByView124
package bp; localparam int A = 3; localparam int B = A + 1; endpackage
package ep; localparam int C = bp::B; endpackage
module top import ep::*; #() (); endmodule
