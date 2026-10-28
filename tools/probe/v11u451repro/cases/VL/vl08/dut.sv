// § pkgDupSignalLeftoverNet451
package a; int va; endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; import a::*; endpackage
module top; endmodule
