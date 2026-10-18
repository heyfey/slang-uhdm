// § deassignReleaseObj401
module top;
  wire [7:0] w; logic [7:0] r;
  task t; assign r = 8'h1; deassign r; endtask
  initial t;
endmodule
