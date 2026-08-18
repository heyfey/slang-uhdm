// r10v66 arm 8 — CALL ARGUMENTS: the position the implementer's grid missed.
// Golden keeps `ref_obj -> enum_const` inside a tf_call argument list.
package vpk8;
  typedef enum logic [3:0] { KH = 4'h3, KB = 4'b0101, KD = 4'd7 } k4_t;
endpackage

module vk8 (input logic [7:0] c1, input logic [7:0] c2, input logic [7:0] c3,
            input logic [7:0] c4, input logic [7:0] c5, input logic [7:0] c6,
            input logic [7:0] c7, input logic [7:0] c8, input logic [7:0] c9);
endmodule

module vtop8;
  import vpk8::*;
  logic [63:0] bus;
  logic [7:0]  ext;
  function automatic logic [7:0] vf8(input logic [7:0] q);
    return q ^ ext;
  endfunction
  function automatic logic [7:0] vg8(input logic [7:0] q, input logic [7:0] r);
    return q ^ r ^ ext;
  endfunction
  vk8 u_c (.c1(vf8(KH)),
           .c2($clog2(KH)),
           .c3(vf8(KH) & 8'h0f),
           .c4(bus[vf8(KH) +: 8]),
           .c5(vg8(KH, KB)),
           .c6({vf8(KH), 4'b0} ),
           .c7($signed(KH)),
           .c8(vf8(bus[KH])),
           .c9(8'(vf8(KD))));
endmodule
