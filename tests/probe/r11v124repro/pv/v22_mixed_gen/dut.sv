// § paramValueIsDefRhs124
module m #(parameter W=1, localparam L = W + 1)(output logic [L-1:0] o); assign o = '1; endmodule
module top(output logic [2:0] o1, output logic [4:0] o2); m #(.W(2)) a(.o(o1)); if (1) begin : g m #(.W(4)) b(.o(o2)); end endmodule
