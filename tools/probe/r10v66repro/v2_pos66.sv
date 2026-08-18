// r10v66 arm 2 — POSITION grid: one package enum read in every position a
// port High_conn actual can hold.
package vpk2;
  typedef enum logic [3:0] { PH = 4'h3, PB = 4'b0101, PD = 4'd7 } p4_t;
endpackage

module vk2 (input logic x1, input logic [3:0] x2, input logic [7:0] x3,
            input logic [7:0] x4, input logic [7:0] x5, input logic [7:0] x6,
            input logic [7:0] x7, input logic [3:0] x8, input logic [3:0] x9,
            input logic [7:0] x10, input logic [1:0] x11, input logic [7:0] x12,
            input logic [3:0] x13, input logic [7:0] x14);
endmodule

module vtop2;
  import vpk2::*;
  logic [63:0] bus;
  logic sel;
  logic [7:0] mem [0:15];
  function automatic logic [7:0] vf2(input logic [7:0] q);
    return q ^ 8'h5a;
  endfunction
  vk2 u_p (.x1 (bus[PH]),
           .x2 (bus[PH +: 4]),
           .x3 (bus[0 +: 8]),
           .x4 (bus[PD -: 4]),
           .x5 (bus[PB : PH]),
           .x6 ({4'b0, PH}),
           .x7 ({2{PH}}),
           .x8 (PH | PB),
           .x9 (sel ? PH : PB),
           .x10(8'(PH)),
           .x11(mem[PH][1:0]),
           .x12(vf2(PH)),
           .x13(PH),
           .x14(bus[0 +: PD]));
  logic [7:0] c1, c2;
  assign c1 = {4'b0, PH};
  assign c2 = bus[PH +: 8];
endmodule
