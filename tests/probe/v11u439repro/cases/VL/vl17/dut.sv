// § loopVarReadBindsModuleDecl439
module top;
wire [3:0] i;
assign i = 4'h3;
logic [3:0] arr[4];
initial foreach (arr[i]) arr[i] = i;
endmodule
