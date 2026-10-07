// § impCopyInitHierPathMemberName285
// a member path inside an operation and a bit select of a member
package p; typedef struct packed { logic [7:0] f; } s_t; s_t st; logic [7:0] b = st.f + 8'd1; logic x = st.f[2]; endpackage
package q; import p::*; class c; int own; endclass endpackage
module m; q::c h; endmodule
