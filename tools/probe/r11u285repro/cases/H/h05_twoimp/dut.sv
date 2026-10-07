// § impCopyInitHierPathMemberName285
// two importing packages, each with a class
package p; typedef struct { int f; } s_t; s_t st; int b = st.f; endpackage
package q; import p::*; class c; int own; endclass endpackage
package r; import p::*; class d; int own; endclass endpackage
module m; q::c h; r::d k; endmodule
