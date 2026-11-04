// § paramValueIsDefRhs124
module m #(parameter int W = 4) (output logic [2*W-1:0] o); localparam int L = W*2; assign o = L; endmodule
module top(output logic [15:0] o); m #(.W(8)) u(.o(o)); endmodule
