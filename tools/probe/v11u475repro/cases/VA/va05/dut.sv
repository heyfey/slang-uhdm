// § addOperandConstMint475
// a generate-block localparam and a module localparam over a 'd origin
module top(output logic [5:0] y, output logic [5:0] z);
  parameter logic [5:0] PA = 6'd33;
  localparam logic [5:0] L = PA + 1;
  if (1) begin : g
    localparam logic [5:0] G = PA + 6'd2;
    assign z = G;
  end
  assign y = L;
endmodule
