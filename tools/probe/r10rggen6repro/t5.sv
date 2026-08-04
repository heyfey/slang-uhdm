module m #(parameter int W = 8, parameter int B = 4)(output logic o);
  genvar g;
  generate
    for (g = 1; g < 3; g++) begin : gd
      localparam bit [W-1:0] A = W'(B * g);
      localparam int         C = B * g;
      localparam int         D = 1 + B * g;
      localparam bit [W-1:0] E = B * g;
      localparam             F = B * g;
      localparam             H = 1 + B * g;
      localparam int         I = 1 + g;
      localparam bit [W-1:0] J = 1 + g;
      localparam bit [W-1:0] K = W'(B * g) + 1;
    end
  endgenerate
  assign o = 1'b0;
endmodule
module top(output logic o);
  m u(o);
endmodule
