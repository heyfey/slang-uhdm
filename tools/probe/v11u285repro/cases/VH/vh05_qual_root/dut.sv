// § impCopyInitHierPathMemberName285
// a package-qualified root
package p; typedef struct { int f; } s_t; s_t st; int b = p::st.f; endpackage
package q; import p::*; class c; int own; endclass endpackage
module m; q::c h; endmodule
