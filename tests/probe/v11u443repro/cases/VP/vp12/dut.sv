// § foreachPackedRefDeclTs443
module top;
function int f(); string ls; int s; ls = "ab"; foreach (ls[i]) s = s + i; return s; endfunction
int r; initial r = f();
endmodule
