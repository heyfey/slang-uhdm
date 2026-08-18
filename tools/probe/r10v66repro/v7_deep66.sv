// r10v66 arm 7 — DEPTH and MIXING: an enum index under a part_select bound
// (the carve-out) that itself sits under an operation; an enum inside a
// function-call argument inside a concat; enum indices at two nesting levels;
// and the same enum read in a param override (a param_assign, not a High_conn).
package vpk7;
  typedef enum logic [3:0] { SH = 4'h3, SB = 4'b0101, SD = 4'd7 } s4_t;
endpackage

module vk7 #(parameter int P = 1) (input logic [7:0] m1, input logic [7:0] m2,
                                   input logic [7:0] m3, input logic [3:0] m4);
endmodule

module vtop7;
  import vpk7::*;
  logic [63:0] bus;
  logic [7:0]  mem [0:15];
  function automatic logic [7:0] vf7(input logic [7:0] q);
    return q + 8'h1;
  endfunction
  vk7 #(.P(SD)) u_d (.m1(bus[SB : SH]),
                     .m2(vf7(bus[SH])),
                     .m3(mem[SH] & {4'b0, SB}),
                     .m4(bus[SH +: 4]));
endmodule
