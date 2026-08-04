package tp2;
  parameter logic [7:0] A = 4'd6;
  parameter int         B = 8'd5;
  parameter logic [7:0] C = 'h3;
  parameter             D = 16'd9;
  parameter bit [3:0]   E = 4'b1010;
endpackage

module m3 #(
  parameter logic [tp2::A-1:0] PA = 'h0,
  parameter logic [tp2::B-1:0] PB = 'h0,
  parameter logic [tp2::C-1:0] PC = 'h0,
  parameter logic [tp2::D-1:0] PD = 'h0,
  parameter logic [tp2::E-1:0] PE = 'h0
) (
  input clk_i
);
endmodule
