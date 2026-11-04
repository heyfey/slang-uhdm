// § clsTdArrElemPkgPath249
package p1; class c; typedef int f_t[2]; f_t m; endclass endpackage
package p2; class c; typedef int f_t[2]; f_t m; endclass endpackage
module top; p1::c a; p2::c b; endmodule
