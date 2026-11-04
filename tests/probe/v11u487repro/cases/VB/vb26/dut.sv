// § bareOvRefUint64_487
package p; localparam P = 5; endpackage
module m #(parameter A = 4) (output logic [7:0] o); localparam B = A; assign o = B; endmodule
module top; logic [7:0] o; m #(.A(p::P)) u(o); endmodule
