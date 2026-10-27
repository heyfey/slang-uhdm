// § foreachPackedRefDeclTs443
module top;
function int f(); logic [7:0] lv; int s; foreach (lv[i]) s = s + i; return s; endfunction
int r; initial r = f();
endmodule
