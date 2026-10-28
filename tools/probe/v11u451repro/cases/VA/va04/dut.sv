// § diamondImportParamAssignsPerPath451
package a; parameter int PA = 3; endpackage
package b; import a::*; export a::*; parameter int PB = PA; endpackage
package c; import a::*; import b::*; endpackage
module top; import c::*; import b::*; logic [PB:0] w; endmodule
