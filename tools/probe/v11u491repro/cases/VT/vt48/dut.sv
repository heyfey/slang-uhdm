// § bitNegTypedOperandSize491
interface ifc #(parameter bit [7:0] A = 4'd4); localparam B = ~A; logic [7:0] o; assign o = B; endinterface
module top; ifc u(); endmodule
