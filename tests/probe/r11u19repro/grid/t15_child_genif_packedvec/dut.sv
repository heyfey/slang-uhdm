module ch(input logic [31:0] a, output logic [1:0] we);
  if (1) begin : gb
    assign we = '{default: '0};
  end
endmodule
module top(input logic [31:0] a, output logic [1:0] o);
  ch u(.a(a), .we(o));
endmodule
