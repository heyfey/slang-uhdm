// § paramValueIsDefRhs124
module top #(parameter int N = 3) (output logic [7:0] o); if (N > 2) begin : g localparam int L = N * 4; assign o = L; end else begin : h assign o = 0; end endmodule
