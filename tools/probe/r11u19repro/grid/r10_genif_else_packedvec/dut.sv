module top(input logic [31:0] a, output logic [1:0] we);
  if (0) begin : gb
    assign we = '{default: '1};
  end else begin : gb2
    assign we = '{default: '0};
  end
endmodule
