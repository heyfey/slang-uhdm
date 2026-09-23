package pk; parameter int unsigned P = 2; endpackage
interface bi import pk::*; ;
  logic [3:0] d; logic y;
  assign y = d[P+1];
endinterface
module top(input logic [3:0] a, output logic y);
  bi u(); assign u.d = a; assign y = u.y;
endmodule
