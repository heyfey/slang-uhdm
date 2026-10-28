// § diamondImportParamAssignsPerPath451
package a; parameter string S = "hi"; typedef struct packed { logic [1:0] f; } s_t; parameter s_t SP = '{f: 2'b10}; endpackage
package b; import a::*; endpackage
package c; import a::*; import b::*; endpackage
package d; import c::*; import b::*; endpackage
module top; import d::*; import a::*; initial $display(S, SP); endmodule
