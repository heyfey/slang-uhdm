// § impCopyInitHierPathMemberName285
// the path ends in a bit select of a member array
package p; typedef struct { int arr [2]; } s_t; s_t st; int b = st.arr[1]; endpackage
package q; import p::*; class c; int own; endclass endpackage
module m; q::c h; endmodule
