// § foreachPackedRefDeclTs443
module top(output logic [3:0] o);
int s;
initial foreach (o[i]) s = s + i;
endmodule
