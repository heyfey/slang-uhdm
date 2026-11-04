// § loopVarReadBindsModuleDecl439
module top;
int i;
int arr[4];
always @* begin : nb
  foreach (arr[i]) arr[i] = i;
end
endmodule
