// § paramEncNoAddLeaf477v
module top(output logic [7:0] z);
  parameter logic [7:0] P = 8'd33;
  localparam logic [7:0] L = P + 8'd1;
  assign z = L & 8'hff;
endmodule
