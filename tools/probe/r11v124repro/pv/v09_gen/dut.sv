// § paramValueIsDefRhs124
module m #(parameter W=1)(output logic [W-1:0] o); assign o = '1; endmodule
module top(output logic [1:0] o1, output logic [2:0] o2); for (genvar i=2;i<4;i++) begin : g m #(.W(i)) u(); end m #(.W(2)) a(.o(o1)); m #(.W(3)) b(.o(o2)); endmodule
