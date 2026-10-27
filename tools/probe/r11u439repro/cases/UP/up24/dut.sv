// § uninstProgBodyAsUninstIface439
program prg;
int x;
initial begin int t; t = 1; if (t > 0) x = t; case (t) 1: x = 2; default: x = 3; endcase end
endprogram
