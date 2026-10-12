// § pkgTdPackedDimsDefNetShares290
package p;
typedef logic [1:0] t;
endpackage
module top();
localparam p::t [1:0] LP = 4'h5;
logic [3:0] y;
assign y = LP;
endmodule
