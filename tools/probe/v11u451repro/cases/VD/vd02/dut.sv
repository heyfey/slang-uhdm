// § diamondImportListsPerPath451
package a; int va; int wa; endpackage
package b; import a::*; int vb; endpackage
package c; import a::va; import b::*; int vc; endpackage
package d; import c::*; endpackage
module top; import d::*; import c::*; initial vc = 1; endmodule
