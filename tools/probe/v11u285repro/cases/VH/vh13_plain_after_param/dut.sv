// § impCopyInitHierPathMemberName285
// a plain member path beside a struct parameter
package p; typedef struct { int f; } s_t; parameter s_t P = '{f: 3}; s_t st; int e = st.f; endpackage
package q; import p::*; class c; int own; endclass endpackage
module m; q::c h; endmodule
