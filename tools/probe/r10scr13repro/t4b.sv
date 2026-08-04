// r10scr13 t4 (file B) — reads file A's $unit names in instance connections.
module sub4 (
    input logic [31:0] a,
    input logic  [1:0] d
);
endmodule

module top4;
xe_t wsig;
sub4 i0 (
    .a (XP),   // $unit localparam declared in the OTHER root file
    .d (XE2)   // $unit enum member declared in the OTHER root file
);
endmodule
