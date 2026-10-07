// § impCopyInitHierPathMemberName285
// a module importing the package (no class copy) beside a class copy
package p; typedef struct { int f; } s_t; s_t st; int b = st.f; endpackage
package q; import p::*; class c; int own; endclass endpackage
module m(output int o); import p::*; q::c h; assign o = b; endmodule
