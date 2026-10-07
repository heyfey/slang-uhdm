// § impCopyInitHierPathMemberName285
// the member path inside a system call argument
package p; typedef struct { logic [7:0] f; } s_t; s_t st; int b = $bits(st.f); int e = $countones(st.f); endpackage
package q; import p::*; class c; int own; endclass endpackage
module m; q::c h; endmodule
