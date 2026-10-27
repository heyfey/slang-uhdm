// § foreachPackedRefDeclTs443
module top;
typedef logic [5:0] w_t;
w_t tv; int s;
initial foreach (tv[i]) s = s + tv[i];
endmodule
