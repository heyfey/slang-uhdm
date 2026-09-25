// § typeParamStructAtKeyword146
module m (input [2:0] i, output [2:0] o);
  localparam type T = struct packed { logic a; logic [1:0] b; };
  T v;
  assign v = i; assign o = v;
endmodule
