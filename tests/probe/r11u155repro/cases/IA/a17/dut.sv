// § implicitArgDimsInner155
module top(); function automatic logic f([2:0] a); return 1; endfunction logic x; assign x = f(3); endmodule
