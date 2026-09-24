module ch(input logic [31:0] a, output logic [1:0] we);
  assign we = '{default: '0};
endmodule
module top(input logic [31:0] a, output logic [1:0] o);
  ch u(.a(a), .we(o));
endmodule
