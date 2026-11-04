// § diamondImportParamAssignsPerPath451
package a; parameter int PA = 3; endpackage
package b; import a::*; parameter int PB = 1; endpackage
package c; import a::*; parameter int PC = 2; endpackage
package d; import b::*; import c::*; endpackage
module sub; import d::*; import a::*; logic [PA:0] w; endmodule
module top; sub u(); endmodule
