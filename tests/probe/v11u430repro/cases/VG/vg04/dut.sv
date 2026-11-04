// § defGenLpNoBlockListed430
module top #(parameter P = 1) (input [3:0] i, output [3:0] o);
  if (P) begin : t
    assign o = i;
  end else begin : e
    localparam a = 5;
    assign o = i + a;
  end
endmodule
