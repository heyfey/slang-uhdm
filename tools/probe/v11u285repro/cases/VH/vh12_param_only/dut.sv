// § impCopyInitHierPathMemberName285
// a struct parameter root alone
package p; typedef struct { int f; } s_t; parameter s_t P = '{f: 3}; s_t st; int b = P.f; endpackage
package q; import p::*; class c; int own; endclass endpackage
module m; q::c h; endmodule
