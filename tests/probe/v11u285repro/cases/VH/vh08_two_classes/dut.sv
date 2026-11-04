// § impCopyInitHierPathMemberName285
// two classes copying the same initializer
package p; typedef struct { int f; } s_t; s_t st; int b = st.f; endpackage
package q; import p::*; class c; int own; endclass class d; int x; endclass endpackage
module m; q::c h; q::d k; endmodule
