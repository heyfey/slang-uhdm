// § foreachPackedRefDeclTs443
package pk; typedef logic [7:0] b_t; endpackage
module top;
pk::b_t v; int s;
initial foreach (v[i]) s = s + i;
endmodule
