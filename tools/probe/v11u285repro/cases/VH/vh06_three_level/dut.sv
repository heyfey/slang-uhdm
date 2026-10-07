// § impCopyInitHierPathMemberName285
// a three-level member path
package p; typedef struct { int h; } j_t; typedef struct { j_t g; } i_t; typedef struct { i_t f; } s_t; s_t st; int b = st.f.g.h; endpackage
package q; import p::*; class c; int own; endclass endpackage
module m; q::c h; endmodule
