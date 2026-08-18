// r10v66 arm 9 — DEPTH UNDER A CALL ARGUMENT.  vf9 is written exactly like
// arm 2's vf2, the one shape Surelog leaves as a func_call in the elaborated
// High_conn, so the compiled ARGUMENTS stay visible in golden.
package vpk9;
  typedef enum logic [3:0] { NH = 4'h3, NB = 4'b0101, ND = 4'd7 } n4_t;
endpackage

module vk9 (input logic [7:0] d1, input logic [7:0] d2, input logic [7:0] d3,
            input logic [7:0] d4, input logic [7:0] d5, input logic [7:0] d6,
            input logic [7:0] d7);
endmodule

module vtop9;
  import vpk9::*;
  logic [63:0] bus;
  function automatic logic [7:0] vf9(input logic [7:0] q);
    return q ^ 8'h5a;
  endfunction
  vk9 u_a (.d1(vf9(NH)),
           .d2(vf9(bus[NH])),
           .d3(vf9(NH | NB)),
           .d4(vf9({4'b0, NH})),
           .d5(bus[(vf9(NH) & 8'h7) +: 8]),
           .d6(vf9(8'(NH))),
           .d7(vf9(bus[NH +: 4])));
endmodule
