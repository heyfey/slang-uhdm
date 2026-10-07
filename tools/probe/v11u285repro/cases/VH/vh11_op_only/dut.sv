// § impCopyInitHierPathMemberName285
// a member path inside an operation, no parameter
package p; typedef struct { int f; } s_t; s_t st; int e = st.f + 1; endpackage
package q; import p::*; class c; int own; endclass endpackage
module m; q::c h; endmodule
