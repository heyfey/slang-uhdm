package tp;
  parameter int TL_AW = 32;
endpackage

module sram2 #(
  parameter int                   SramAw = 12,
  parameter logic [tp::TL_AW-1:0] TlBaseAddr = 'h0
) (
  input clk_i
);
endmodule
