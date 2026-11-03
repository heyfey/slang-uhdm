// § paramEncNoAddLeaf477v
module top(output logic [7:0] z);
  parameter logic [7:0] P = 8'd33;
  localparam logic [7:0] L = P + 8'd1;
  localparam logic [7:0] M = L & 8'hff;
  assign z = M;
endmodule
