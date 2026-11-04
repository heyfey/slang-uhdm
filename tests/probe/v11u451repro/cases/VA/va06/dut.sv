// § diamondImportParamAssignsPerPath451
package a; parameter int PA = 3; endpackage
package b; import a::PA; endpackage
package c; import a::*; import b::*; endpackage
module top; import c::*; import a::*; logic [PA:0] w; endmodule
