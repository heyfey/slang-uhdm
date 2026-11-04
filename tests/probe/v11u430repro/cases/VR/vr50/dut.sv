// § rngGenLpCaReadShape430v
module top (input [7:0] i, output [7:0] o);
  for (genvar k = 0; k < 1; k++) begin : g
    localparam [7:0] a = 5;
    assign o = ~a + i;
  end
endmodule
