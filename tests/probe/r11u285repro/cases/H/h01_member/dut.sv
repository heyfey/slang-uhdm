// § impCopyInitHierPathMemberName285
// a member path initializer copied into a class
package p; typedef struct { int f; } s_t; s_t st; int b = st.f; endpackage
package q; import p::*; class c; int own; endclass endpackage
module m; q::c h; endmodule
