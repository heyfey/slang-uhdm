// § foreachPackedRefDeclTs443
module top;
typedef logic [7:0] b_t;
b_t v; int s;
initial foreach (v[i]) s = s + i;
endmodule
