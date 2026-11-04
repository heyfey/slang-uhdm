// § paramValueIsDefRhs124
module leaf #(parameter W=2)(output logic [W-1:0] o); assign o = '1; endmodule
module mid #(parameter W=3)(output logic [W-1:0] o); leaf #(.W(W)) l(.o(o)); endmodule
module top(output logic [5:0] o); mid #(.W(6)) m(.o(o)); endmodule
