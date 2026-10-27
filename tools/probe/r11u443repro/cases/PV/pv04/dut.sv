// § foreachPackedRefDeclTs443
module top(input logic [3:0] pin);
int s;
initial foreach (pin[i]) s = s + pin[i];
endmodule
