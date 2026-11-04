// § pkgDupSignalLeftoverNet451
package a; int va; logic [2:0] lb; endpackage
package c; import a::va; import a::*; endpackage
module top; endmodule
