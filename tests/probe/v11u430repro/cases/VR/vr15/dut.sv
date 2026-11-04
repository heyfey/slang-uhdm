// § rngGenLpCaReadShape430v
module top (input [3:0] i, output [3:0] o, output [3:0] o2);
  if (1) begin : b
    localparam [7:0] a = 2;
    assign o2 = i >> a;
  end
  if (1) begin : t
    localparam [3:0] a = 1;
    assign o = i << a;
  end
endmodule
