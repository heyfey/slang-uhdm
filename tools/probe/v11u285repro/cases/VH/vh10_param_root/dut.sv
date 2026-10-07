// § impCopyInitHierPathMemberName285
// a struct parameter root and a member of a struct variable side by side
package p; typedef struct { int f; } s_t; parameter s_t P = '{f: 3}; s_t st; int b = P.f; int e = st.f + 1; endpackage
package q; import p::*; class c; int own; endclass endpackage
module m; q::c h; endmodule
