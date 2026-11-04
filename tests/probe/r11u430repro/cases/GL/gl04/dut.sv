// § defGenLpRangedTs430
module top #(parameter P = 0) (input [3:0] i, output [3:0] o);
  if (P) begin : g
     localparam K = P * 2;
     localparam [7:0] M = K + 1;
     assign o = i + K;
  end else begin : h
     assign o = i;
  end
endmodule
