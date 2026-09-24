package tp;
  parameter int TL_AW = 32;
  parameter int NMioPads = 12;
endpackage

module sram2 #(
  parameter int                   SramAw = 12,
  parameter logic [tp::TL_AW-1:0] TlBaseAddr = 'h0
) (
  input clk_i
);
endmodule

module padr import tp::*; #(
  parameter logic [NMioPads-1:0] ConnectMioIn = '1
) (
  input clk_i
);
endmodule
