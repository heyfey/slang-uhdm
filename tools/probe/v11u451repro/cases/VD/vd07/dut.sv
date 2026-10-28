// § diamondImportListsPerPath451
package a; int va; function automatic int fa(); return va; endfunction endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; endpackage
module top; import c::*; endmodule
