// § unaryOperandParamOwnerName145
module sub ();
  parameter logic [7:0] M = 8'h0F;
  logic [7:0] a [2];
  logic [7:0] o [2];
  if (1) begin : g
    localparam int c = 0;
    assign o[c] = a[c] | -M;
  end
endmodule
module dut ();
  sub #(.M(8'h33)) u();
endmodule
