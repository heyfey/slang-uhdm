// § impCopyInitHierPathMemberName285
// two member paths in a concatenation and a ternary
package p; typedef struct { logic [3:0] f; logic [3:0] g; } s_t; s_t st; logic [7:0] b = {st.f, st.g}; logic [3:0] e = st.f[0] ? st.f : st.g; endpackage
package q; import p::*; class c; int own; endclass endpackage
module m; q::c h; endmodule
