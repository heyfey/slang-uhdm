// § qspanPhysDefView124v
package q; parameter int QC = 6; endpackage
package pk; parameter int NX = q::QC; endpackage
module m (output int o); import pk::*; assign o = NX; endmodule
module top(output int o); m u(.o(o)); endmodule
