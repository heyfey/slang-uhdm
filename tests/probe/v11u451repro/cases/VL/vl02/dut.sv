// § pkgDupSignalLeftoverNet451
package a; int va; wire [1:0] wa; logic lb; endpackage
package b; import a::*; endpackage
package c; import b::*; import a::*; endpackage
module top; endmodule
