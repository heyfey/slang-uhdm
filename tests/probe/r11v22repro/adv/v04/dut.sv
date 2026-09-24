module sub #(parameter int SP = 1)(input logic c, output logic d);
  assign d = c;
endmodule
module top(input logic [31:0] a, output logic [31:0] o);
  sub #(.SP(1)) u_sub(.c(1'b0), .d());
  if (1) begin : gb
    assign o = (u_sub.SP == 1) ? 32'd7 : '0;
  end
endmodule
