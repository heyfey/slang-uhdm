// § foreachPackedRefDeclTs443
module top(input wire [3:0] a, output logic [3:0] y);
always_comb foreach (y[i]) y[i] = a[i];
endmodule
