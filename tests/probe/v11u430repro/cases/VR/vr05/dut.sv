// § defGenLpRangedTs430
module sub (input [7:0] x, output [7:0] y); assign y = x; endmodule
module top (output [7:0] o);
  for (genvar k = 0; k < 1; k++) begin : g
    localparam [7:0] a = 8'h3C;
    sub u(.x(a), .y(o));
  end
endmodule
