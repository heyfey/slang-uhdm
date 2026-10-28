// § diamondImportListsPerPath451
package a; int va; endpackage
package b; import a::*; endpackage
package c; import a::*; endpackage
module top; import b::*; import c::*; int x; initial x = 1; endmodule
