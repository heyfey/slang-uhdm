// § uninstProgBodyAsUninstIface439
program prg (input logic clk);
int cnt;
initial begin @(posedge clk); cnt = cnt + 1; end
endprogram
