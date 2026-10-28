// § diamondImportParamAssignsPerPath451
package a; parameter int PA = 1; localparam int LA = PA + 1; parameter type T = int; endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; endpackage
module top; import c::*; import a::*; T x; initial x = LA; endmodule
