// § qspanPhysDefView124v
package q; localparam logic [3:0] QC = 4'h6; endpackage
package pk; localparam logic [3:0] NX = q::QC; endpackage
module m #(parameter int MP = 3) (output logic [3:0] o); import pk::*; assign o = NX; endmodule
module top(output logic [3:0] o); m u(.o(o)); endmodule
