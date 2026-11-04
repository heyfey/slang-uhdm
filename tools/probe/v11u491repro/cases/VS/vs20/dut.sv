// § unboundedSubSize64_491
interface ifc #(parameter A = 4'd3); localparam B = A - 4'd1; logic [7:0] o; assign o = B + 1; endinterface
module top; ifc u(); endmodule
