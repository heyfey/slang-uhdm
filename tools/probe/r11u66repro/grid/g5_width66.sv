// r11u66 arm g5 — THE WIDTH CONTROLS (caution (b)).  The pass-60 / pass-63
// width laws own the SIZE half of these operands; this arm carries one
// INT-answering and one UINT-answering setter at every member width so the
// size stamps are visible as CONTROLS beside the encoding cells.  A concat,
// a replication and a nested pattern ride along as landed-ground controls.
package q5;
  localparam int K = 6;
  localparam int unsigned KU = 6;
  typedef struct packed {
    logic [3:0]  i4;    // K - 2   INT arm at a 4-bit member
    logic [3:0]  u4;    // KU >> 1 UINT arm at a 4-bit member
    logic [7:0]  i8;    // K * 2   INT arm at an 8-bit member
    logic [7:0]  u8;    // KU | 8  UINT arm at an 8-bit member
    logic [15:0] i16;   // K / 2
    logic [15:0] u16;   // KU & 3
    logic [31:0] i32;   // K ** 2
    logic [31:0] u32;   // KU << 1
    logic [63:0] i64;   // K % 4
    logic [63:0] u64;   // KU >>> 1
    logic [11:0] cat;   // {4'b1010, 4'b0101, 4'b0011}  concat control
    logic [11:0] rep;   // {3{4'b1010}}                 replication control
    logic [4:0]  lit;   // 4'b1111                      based-literal control
  } c5_t;
  localparam c5_t L5 = '{i4: K - 2, u4: KU >> 1, i8: K * 2, u8: KU | 8,
                         i16: K / 2, u16: KU & 3, i32: K ** 2, u32: KU << 1,
                         i64: K % 4, u64: KU >>> 1,
                         cat: {4'b1010, 4'b0101, 4'b0011},
                         rep: {3{4'b1010}}, lit: 4'b1111};
endpackage
module g5_width66 #(parameter q5::c5_t C = q5::L5)
                  (output logic [3:0] o01,  output logic [3:0] o02,
                   output logic [7:0] o03,  output logic [7:0] o04,
                   output logic [15:0] o05, output logic [15:0] o06,
                   output logic [31:0] o07, output logic [31:0] o08,
                   output logic [63:0] o09, output logic [63:0] o10,
                   output logic [11:0] o11, output logic [11:0] o12,
                   output logic [4:0] o13);
  assign o01 = C.i4;  assign o02 = C.u4;  assign o03 = C.i8;  assign o04 = C.u8;
  assign o05 = C.i16; assign o06 = C.u16; assign o07 = C.i32; assign o08 = C.u32;
  assign o09 = C.i64; assign o10 = C.u64; assign o11 = C.cat; assign o12 = C.rep;
  assign o13 = C.lit;
endmodule
