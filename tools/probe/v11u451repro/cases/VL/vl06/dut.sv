// § pkgDupSignalLeftoverNet451
package a; int va; endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; endpackage
module top; import c::*; import a::*; int x; initial x = va; endmodule
