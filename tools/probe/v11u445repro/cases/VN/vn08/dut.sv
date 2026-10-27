// § foreachLoopVarModParamTs445
module top;
int arr[4]; int s;
if (1) begin : g
  localparam int i = 1;
  initial foreach (arr[i]) s = s + i;
end
endmodule
