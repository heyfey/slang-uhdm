// § qspanPhysDefView124v
package q; parameter int QC = 6; endpackage
package pk; parameter int NX = q::QC; parameter int NY = 2; endpackage
module m #(parameter int MP = 3) (output int o); import pk::NX; assign o = NX + MP; endmodule
module top(output int o); m #(.MP(4)) u(.o(o)); endmodule
