// § impCopyInitHierPathMemberName285
// a two-level member path
package p; typedef struct { int g; } i_t; typedef struct { i_t f; } s_t; s_t st; int b = st.f.g; endpackage
package q; import p::*; class c; int own; endclass endpackage
module m; q::c h; endmodule
