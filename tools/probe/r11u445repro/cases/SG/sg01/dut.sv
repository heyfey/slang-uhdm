// § foreachLoopVarShadowDeclTs445
module top;
int arr[4];
if (1) begin : g
  initial begin int i; foreach (arr[i]) arr[i] = i; end
end
endmodule
