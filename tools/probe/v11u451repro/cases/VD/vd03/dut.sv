// § diamondImportListsPerPath451
package a; int va; endpackage
package b; import a::*; export a::*; int vb = va; endpackage
package c; import a::*; export a::*; int vc = va; endpackage
package d; import b::*; import c::*; export *::*; int vd = va; endpackage
module top; import d::*; initial va = 1; endmodule
