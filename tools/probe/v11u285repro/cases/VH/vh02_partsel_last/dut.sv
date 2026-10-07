// § impCopyInitHierPathMemberName285
// the path ends in a part select of a packed member
package p; typedef struct { logic [7:0] f; } s_t; s_t st; logic [3:0] b = st.f[3:0]; endpackage
package q; import p::*; class c; int own; endclass endpackage
module m; q::c h; endmodule
