// § untypedDepUnboundedValue489
interface ifc #(parameter A = 4'd15); localparam B = A + 4'd1; logic [7:0] o; assign o = B; endinterface
module top; ifc u(); endmodule
