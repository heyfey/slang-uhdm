// § loopVarReadBindsModuleDecl439
module top;
int item;
int arr[4];
int idx[$];
initial begin idx = arr.find_index with (item == 1); arr.sort with (item); end
endmodule
