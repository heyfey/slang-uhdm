// § qspanPhysDefView124v
package q; parameter int QC = 6; endpackage
package pk; parameter int NX = q::QC; endpackage
module m import pk::*; #(parameter int MP = 3) (output int o); assign o = NX + MP; endmodule
module top(output int o); m u(.o(o)); endmodule
