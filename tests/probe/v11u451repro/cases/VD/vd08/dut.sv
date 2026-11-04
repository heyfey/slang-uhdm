// § diamondImportListsPerPath451
package a; int va; endpackage
package b; import a::*; int vb; endpackage
package c; import b::*; import a::*; int vc; endpackage
module m1; import c::*; initial vc = 2; endmodule
module top; import c::*; m1 u(); initial vc = 1; endmodule
