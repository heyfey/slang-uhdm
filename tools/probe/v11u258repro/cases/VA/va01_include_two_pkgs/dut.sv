// § cloneLoopVarAssocIdxTs258 (one header with the foreach included into two packages: the same keyword location for two homes)
package p1;
`include "body.svh"
endpackage
package p2;
`include "body.svh"
endpackage
package q1; import p1::*; endpackage
package q2; import p2::*; endpackage
module top; import p1::*; endmodule
module top2; import p2::*; endmodule
