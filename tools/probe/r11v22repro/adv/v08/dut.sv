module top(input logic [62:0] a, output logic [62:0] o63, output logic [64:0] o65);
  if (1) begin : gb
    assign o63 = (1) ? '1 : '0;
    assign o65 = (1) ? '1 : '0;
  end
endmodule
