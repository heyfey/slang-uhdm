module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] marr [2];
  if (1) begin : gb
    logic [31:0] loc [2];
    assign loc = marr;
  end
  assign o = a;
endmodule
