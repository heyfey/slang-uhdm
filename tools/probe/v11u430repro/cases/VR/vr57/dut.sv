// § defGenLpRangedTs430
module sub (input [7:0] x, output [7:0] y); assign y = x; endmodule
module top (input [7:0] i, output [7:0] o, output [7:0] o2);
  for (genvar k = 0; k < 1; k++) begin : g
    localparam [7:0] a = 5;
    assign o = i + a;
    sub u(.x(a), .y(o2));
  end
endmodule
