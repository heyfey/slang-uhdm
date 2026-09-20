// r11v69 w3 — MEMBER WIDTH x Lhs WIDTH inside a generate block, every target a
// module-body variable (so the law fires on every row) and every row twinned at
// module level.  This is `adjustSize`'s table (W3) re-measured in the generate
// home: equal, narrower (mask) and wider (zero-extend) for a 32-bit member, an
// 8-bit member and a 64-bit member.
package p;
  typedef struct packed {
    int unsigned n32;   // 32, value 300  -> 8 bits masks to 44
    logic [7:0]  n8;    // 8,  value 0xA5
    logic [63:0] n64;   // 64, value 70000
  } cfg_t;
  localparam cfg_t LIT = '{n32: 300, n8: 8'hA5, n64: 64'd70000};
endpackage

module dut #(parameter p::cfg_t CFG = p::LIT)
  (input logic a_i,
   output logic [31:0] o0, o1, o2, o3, o4, o5, o6, o7, o8,
   output logic [31:0] q0, q1, q2, q3, q4, q5, q6, q7, q8);

  logic [31:0] e32; logic [7:0] s32; logic [63:0] w32;
  logic [31:0] e8;  logic [3:0] s8;  logic [63:0] w8;
  logic [31:0] e64; logic [7:0] s64; logic [95:0] w64;

  logic [31:0] te32; logic [7:0] ts32; logic [63:0] tw32;
  logic [31:0] te8;  logic [3:0] ts8;  logic [63:0] tw8;
  logic [31:0] te64; logic [7:0] ts64; logic [95:0] tw64;

  // module-level twins
  assign te32 = CFG.n32; assign ts32 = CFG.n32; assign tw32 = CFG.n32;
  assign te8  = CFG.n8;  assign ts8  = CFG.n8;  assign tw8  = CFG.n8;
  assign te64 = CFG.n64; assign ts64 = CFG.n64; assign tw64 = CFG.n64;

  if (1) begin : gw
    assign e32 = CFG.n32; assign s32 = CFG.n32; assign w32 = CFG.n32;
    assign e8  = CFG.n8;  assign s8  = CFG.n8;  assign w8  = CFG.n8;
    assign e64 = CFG.n64; assign s64 = CFG.n64; assign w64 = CFG.n64;
  end

  assign o0 = e32; assign o1 = {24'd0, s32}; assign o2 = w32[31:0];
  assign o3 = e8;  assign o4 = {28'd0, s8};  assign o5 = w8[31:0];
  assign o6 = e64; assign o7 = {24'd0, s64}; assign o8 = w64[31:0];
  assign q0 = te32; assign q1 = {24'd0, ts32}; assign q2 = tw32[31:0];
  assign q3 = te8;  assign q4 = {28'd0, ts8};  assign q5 = tw8[31:0];
  assign q6 = te64; assign q7 = {24'd0, ts64}; assign q8 = tw64[31:0];
endmodule
