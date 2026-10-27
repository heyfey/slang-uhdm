// § loopVarReadBindsModuleDecl439
module top;
int i;
int arr[4];
int brr[3];
initial begin
  foreach (arr[i]) arr[i] = i;
  foreach (brr[i]) brr[i] = i + 1;
end
endmodule
