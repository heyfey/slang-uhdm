module top #(parameter logic [1:0][15:0] PA = 32'h0003_0004)
  (input logic [31:0] a, output logic [31:0] o);
  if (1) begin : gb
    assign o = (1) ? PA[1:0] : '0;
  end
endmodule
