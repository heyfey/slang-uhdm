// § cgArrayElemUnsupportedTs436
module top(input clk, input a);
covergroup cg; coverpoint a; endgroup
generate if (1) begin : g
cg c2[2];
end endgenerate
endmodule
