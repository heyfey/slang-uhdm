// § impCopyInitHierPathMemberName285
// an array element root
package p; typedef struct { int f; } s_t; s_t sa [2]; int b = sa[0].f; endpackage
package q; import p::*; class c; int own; endclass endpackage
module m; q::c h; endmodule
