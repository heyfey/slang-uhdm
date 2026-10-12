// § pkgTdPackedDimsDefNetShares290
package p;
typedef logic [1:0] t;
endpackage
module top();
typedef struct packed { p::t [2:0] f; } s_t;
s_t s;
p::t [1:0] x;
endmodule
