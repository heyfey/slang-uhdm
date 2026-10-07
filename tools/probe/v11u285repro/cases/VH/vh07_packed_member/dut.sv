// § impCopyInitHierPathMemberName285
// a packed struct root
package p; typedef struct packed { logic [3:0] f; logic [3:0] g; } s_t; s_t st; logic [3:0] b = st.g; endpackage
package q; import p::*; class c; int own; endclass endpackage
module m; q::c h; endmodule
