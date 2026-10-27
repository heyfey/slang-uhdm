// § uninstProgBodyAsUninstIface439
program prg (input clk, input a);
logic [3:0] arr[4];
initial foreach (arr[i]) arr[i] = {a, a, a, a};
endprogram
