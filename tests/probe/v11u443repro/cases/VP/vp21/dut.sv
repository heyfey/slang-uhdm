// § foreachPackedRefDeclTs443
module top;
logic [7:0] v; int s;
function void f(); foreach (v[i]) s = s + i; endfunction
initial f();
endmodule
