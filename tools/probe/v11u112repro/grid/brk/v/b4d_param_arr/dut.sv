module m(input logic [2:0] o, output logic [3:0] y [2]);
  localparam logic [7:0] T [2] = '{8'hA5, 8'h3C};
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = T[i][o +: 4];
  end
endmodule
