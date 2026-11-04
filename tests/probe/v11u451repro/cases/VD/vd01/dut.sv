// § diamondImportListsPerPath451
package a; int va; logic [3:0] la; endpackage
package b; import a::*; int vb; endpackage
package c; import a::*; int vc; endpackage
package d; import b::*; import c::*; int vd; endpackage
package e; import d::*; int ve; endpackage
module top; import e::*; initial ve = 1; endmodule
