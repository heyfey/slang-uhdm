// § loopVarReadBindsModuleDecl439
module top;
int arr[4];
task automatic t();
  int i;
  begin
    foreach (arr[i]) arr[i] = i;
  end
endtask
initial t();
endmodule
