// § paramEncNoAddLeaf477v
module top(output logic [7:0] z);
  parameter logic [7:0] P = 8'd33;
  parameter logic [7:0] Q = 8'd5;
  localparam L = P + 8'd1;
  localparam M = L & 8'hff;
  logic [L-1:0] y;
  assign z = M + y[0];
endmodule
