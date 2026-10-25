// § rngGenLpCaReadShape430v
module top (input [3:0] i, output [3:0] o);
  for (genvar k = 0; k < 2; k++) begin : g
    localparam [7:0] a = 300;
    localparam [3:0] b = 'hFF;
    assign o[k] = i[a[1:0] + b[0]];
  end
endmodule
