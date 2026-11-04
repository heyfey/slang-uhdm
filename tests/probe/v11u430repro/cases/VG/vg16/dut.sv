// § defGenLpNoBlockListed430
module top #(parameter P = 0) (input [3:0] i, output [3:0] o);
  if (P) begin : t
    localparam a = 2, b = 3;
    localparam int c = a;
    assign o = i + a + b + c;
  end else begin : e
    assign o = i;
  end
endmodule
