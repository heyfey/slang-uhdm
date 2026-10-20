// § badCastSizeNoExpr415
module sub(input logic [1:0] a, output logic o);
  assign o = a[0];
endmodule
module top #(parameter W = 2) (input logic [3:0] x, output logic [3:0] z);
  for (genvar i = 0; i < 4; i++) begin : g
    if (i > 1) begin : h
      sub u (.a(W'(x[i])), .o(z[i]));
    end else begin : k
      sub u (.a(W'(x[i])), .o(z[i]));
    end
  end
endmodule
