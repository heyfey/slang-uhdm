// § dpDepBitNegUint489
module top #(parameter A = 4) (output logic [7:0] o); localparam B = ~A; assign o = B; endmodule

