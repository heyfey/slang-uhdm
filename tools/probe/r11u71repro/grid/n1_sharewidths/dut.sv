// r11u71 n1 — THE SHARE HALF ACROSS ENCODINGS x Lhs WIDTHS.  Every target is a
// gen-local with NO namesake anywhere, so `bindVariable` finds nothing, `tps`
// stays null and `adjustSize` returns at once: the MEMBER's own width and the
// member's own spelling must stand whatever the Lhs says.
package p;
  typedef struct packed {
    logic [7:0]  h8;      // hex literal, 8-bit member
    logic [15:0] d16;     // based decimal, 16-bit member
    logic [15:0] b16;     // based binary, 16-bit member
    int unsigned u32;     // plain decimal
    logic [63:0] w64;     // wide
    logic [7:0]  o8;      // '1 fill on a narrow member
    logic [31:0] k32;     // an expression setter
  } cfg_t;
  localparam cfg_t LIT = '{h8: 8'hA5, d16: 16'd4660, b16: 16'b1010010111000011,
                           u32: 300, w64: 64'd70000, o8: '1, k32: 12 + 1};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic a_i, output logic [63:0] o);
  if (1) begin : g
    logic [31:0] n_h8;    // member 8  -> Lhs 32
    logic [3:0]  n_d16;   // member 16 -> Lhs 4
    logic [3:0]  n_b16;   // member 16 -> Lhs 4
    logic [7:0]  n_u32;   // member 32 -> Lhs 8
    logic [31:0] n_w64;   // member 64 -> Lhs 32
    logic [63:0] n_o8;    // member 8  -> Lhs 64
    logic [7:0]  n_k32;   // member 32 -> Lhs 8
    assign n_h8  = CFG.h8;
    assign n_d16 = CFG.d16;
    assign n_b16 = CFG.b16;
    assign n_u32 = CFG.u32;
    assign n_w64 = CFG.w64;
    assign n_o8  = CFG.o8;
    assign n_k32 = CFG.k32;
    assign o = {n_h8, n_d16} ^ {n_b16, n_u32} ^ {n_w64} ^ n_o8 ^ {56'd0, n_k32};
  end
endmodule
