// § diamondImportParamAssignsPerPath451
package a; parameter int PA = 3; endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; endpackage
module top #(parameter int PA = 5); import c::*; logic [PA:0] w; endmodule
