// § macroBodyTrailingComment125
`define W 8 /* c */ // d
module top(output logic [`W-1:0] o, output logic p);
  logic [`W-1:0] x; assign p = 1'b0;
  assign o = x;
endmodule
