// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
if (1) begin : g int i; initial foreach (arr[i]) arr[i] = i; end
endmodule
