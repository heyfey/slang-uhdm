module top(input logic [31:0] a, input logic [3:0] idx, output logic [31:0] o);
  logic [3:0][7:0] mem;
  if (1) begin : gb
    assign o = (1) ? mem[idx][3:0] : '0;
  end
endmodule
