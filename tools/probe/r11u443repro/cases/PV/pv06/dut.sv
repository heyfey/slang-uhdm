// § foreachPackedRefDeclTs443
module top;
function automatic int f(logic [3:0] a); int s = 0; foreach (a[i]) s += a[i]; return s; endfunction
initial $display(f(4'h3));
endmodule
