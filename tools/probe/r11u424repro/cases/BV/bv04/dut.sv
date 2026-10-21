// § boundSizedLitKept424
module top(input logic [4'd7:0] a, output logic [7:3'd0] o);
  logic [8'd15:0] v;
  wire [2'd3:0] w;
  parameter logic [3'd5:0] P = 0;
  struct packed { logic [2'b11:0] m; } s;
  assign o = a;
endmodule
