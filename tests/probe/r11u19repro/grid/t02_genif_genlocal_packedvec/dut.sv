module top(input logic [31:0] a, output logic [1:0] o);
  if (1) begin : gb
    logic [1:0] we;
    assign we = '{default: '0};
    assign o = we;
  end
endmodule
