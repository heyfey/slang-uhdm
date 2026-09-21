// r11v75 xb — LAW A's FENCE, on the store it was NOT measured on.  The fence
// nulls an `array_net` however it was reached, INCLUDING through `netMap` —
// which is the store pass 73 already used.  A MODULE-BODY unpacked-array net
// namesake is therefore a pristine binding this patch removes; g4_edges only
// measured the gen-scope-declared one.
module dut (input logic [7:0] a_i, output logic [7:0] o);
  wire [7:0]      mb_arr [0:1];   // module-body UNPACKED-ARRAY net namesake
  wire [1:0][7:0] mb_pk;          // module-body PACKED-array net namesake
  logic [7:0]     mb_uv [0:1];    // module-body unpacked-array VARIABLE namesake
  assign mb_arr[0] = a_i;
  assign mb_arr[1] = a_i;
  assign mb_pk = {a_i, a_i};
  for (genvar i = 0; i < 1; i = i + 1) begin : g1
    wire [7:0] e_arr [0:1];       // gen-scope array net, one scope out from g2
    assign e_arr[0] = a_i;
    logic [7:0]      mb_arr;  assign mb_arr = a_i;   // namesake: module ARRAY NET
    logic [1:0][7:0] mb_pk;   assign mb_pk  = {a_i, a_i}; // namesake: packed array net
    logic [7:0]      mb_uv;   assign mb_uv  = a_i;   // namesake: array VARIABLE
    if (1) begin : g2
      logic [7:0] e_arr; assign e_arr = a_i;         // namesake: gen ARRAY NET
    end
  end
  assign o = g1[0].mb_arr ^ g1[0].mb_pk[0] ^ g1[0].mb_uv ^ g1[0].g2.e_arr
           ^ mb_arr[0] ^ mb_pk[0] ^ mb_uv[0];
endmodule
