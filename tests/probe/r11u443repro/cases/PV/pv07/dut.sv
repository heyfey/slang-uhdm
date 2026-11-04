// § foreachPackedRefDeclTs443
package pk;
logic [3:0] pvv;
function automatic int f(); int s = 0; foreach (pvv[i]) s += pvv[i]; return s; endfunction
endpackage
module top; import pk::*; initial $display(f()); endmodule
