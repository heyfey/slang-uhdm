// r10v66 arm 1 — ENCODING grid: every written enum-member form read as the
// INDEX of a bit_select in an ELABORATED port High_conn.  Negative controls:
// the same read in a cont_assign and in a procedural block.
package vpk1;
  typedef enum logic [3:0] {
    EH = 4'h3,
    EB = 4'b0101,
    ED = 4'd7,
    EO = 4'o1,
    EA,
    ES = 4'sd6
  } e4_t;
  typedef enum { UA = 2, UB, UC = 9 } eu_t;
  typedef enum int { IA = 3, IB = 11 } ei_t;
  typedef enum byte { BY = 8'h7f } eby_t;
  typedef enum logic [7:0] { EM = 8'd5, EN = 8'b10100101 } e8_t;
  typedef enum bit [15:0] { BG = 16'hbeef } eb_t;
endpackage

module vk1 (input logic a0, input logic a1, input logic a2, input logic a3,
            input logic a4, input logic a5, input logic a6, input logic a7,
            input logic a8, input logic a9, input logic a10, input logic a11);
endmodule

module vtop1;
  import vpk1::*;
  logic [255:0] bus;
  logic n0, n1;
  vk1 u_g (.a0 (bus[EH]),
           .a1 (bus[EB]),
           .a2 (bus[ED]),
           .a3 (bus[EO]),
           .a4 (bus[EA]),
           .a5 (bus[ES]),
           .a6 (bus[UA]),
           .a7 (bus[UC]),
           .a8 (bus[IA]),
           .a9 (bus[BY]),
           .a10(bus[EM]),
           .a11(bus[EN]));
  assign n0 = bus[EH];
  always_comb n1 = bus[EM];
endmodule
