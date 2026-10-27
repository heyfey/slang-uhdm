// § uninstProgBodyAsUninstIface439
program prg;
logic [7:0] v;
int x;
initial begin x = v[3]; x = v[5:2]; x = {v, v}; x = v ? 1 : 0; x = $bits(v); end
endprogram
