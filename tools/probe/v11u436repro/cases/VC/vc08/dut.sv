// § cgArrayElemUnsupportedTs436
module top(input clk, input a);
covergroup cg; coverpoint a; endgroup
function void f();
cg loc[2];
endfunction
endmodule
