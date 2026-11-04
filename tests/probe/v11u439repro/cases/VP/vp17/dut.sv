// § uninstProgBodyAsUninstIface439
program prg;
parameter int N = 4;
localparam int M = N + 1;
int x;
initial begin x = N; x = M * 2; end
endprogram
