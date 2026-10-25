// § rngGenLpCaReadShape430v
module top #(parameter P = 1) (input [3:0] i, output [3:0] o);
  if (P) begin : t
    parameter [3:0] a = 4'd3;
    assign o = i + a;
  end else begin : e
    assign o = i;
  end
endmodule
