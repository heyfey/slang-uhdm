// r11u39 arm a1 — GOLDEN GRID: path-element shape for a member select chain.
// axes: ROOT select count (0/1/2/3) x MEMBER tail index count (0/1/2/3)
//       x index kind (constant / parameter / genvar / dynamic net)
package p1;
  typedef struct packed {
    logic             v;
    logic [3:0][1:0]  sat;        // 2 packed dims on the member
  } e_t;
  typedef struct packed {
    logic [1:0][3:0][1:0] deep;   // 3 packed dims on the member
    e_t                    sub;
  } f_t;
endpackage

module dut (
    input  logic        r_i,
    input  logic        c_i,
    input  logic [1:0]  s_i,
    input  logic [0:0]  t_i,
    input  logic [255:0] flat_i,
    output logic        o00, o01, o02, o03,
    output logic        o10, o11, o12, o13,
    output logic        o20, o21, o22, o23,
    output logic        o30, o31, o32, o33,
    output logic        k1, k2, k3, k4, k5, k6, k7, k8
);
  localparam int K = 1;
  p1::e_t                      m0;      // root dims 0
  p1::e_t [1:0]                m1;      // root dims 1
  p1::e_t [1:0][1:0]           m2;      // root dims 2
  p1::e_t [1:0][1:0][1:0]      m3;      // root dims 3
  p1::f_t [1:0][1:0]           g2;      // root dims 2, member 3 dims

  assign m0 = flat_i[8:0];
  assign m1 = flat_i[17:0];
  assign m2 = flat_i[35:0];
  assign m3 = flat_i[71:0];
  assign g2 = flat_i[95:0];

  // ---- ROOT 0 dims  x  member tail 0/1/2 --------------------------------
  assign o00 = m0.v;
  assign o01 = m0.sat[s_i][1];
  assign o02 = m0.sat[s_i];
  assign o03 = m0.sat[2][0];

  // ---- ROOT 1 dim (dynamic) x member tail 0/1/2 -------------------------
  assign o10 = m1[r_i].v;
  assign o11 = m1[r_i].sat[s_i];
  assign o12 = m1[r_i].sat[s_i][1];
  assign o13 = m1[r_i].sat[2][0];

  // ---- ROOT 2 dims (dynamic) x member tail 0/1/2 ------------------------
  assign o20 = m2[r_i][c_i].v;
  assign o21 = m2[r_i][c_i].sat[s_i];
  assign o22 = m2[r_i][c_i].sat[s_i][1];
  assign o23 = m2[r_i][c_i].sat[2][0];

  // ---- ROOT 3 dims (dynamic) x member tail 0/1/2 ------------------------
  assign o30 = m3[r_i][c_i][t_i].v;
  assign o31 = m3[r_i][c_i][t_i].sat[s_i];
  assign o32 = m3[r_i][c_i][t_i].sat[s_i][1];
  assign o33 = m3[r_i][c_i][t_i].sat[2][0];

  // ---- index KIND on the member tail (root 2 dims constant) -------------
  assign k1 = m2[0][1].sat[s_i][1];      // const root, dyn+const member
  assign k2 = m2[0][1].sat[K][0];        // const root, localparam+const member
  assign k3 = m2[r_i][c_i].sat[K][1];    // dyn root, localparam+const member
  assign k4 = m2[r_i][c_i].sat[s_i][t_i];// dyn root, dyn+dyn member

  // ---- THREE indices on the member tail ---------------------------------
  assign k5 = g2[r_i][c_i].deep[t_i][s_i][1];
  assign k6 = g2[r_i][c_i].deep[0][1][0];

  // ---- nested member below a selected member (mid-path multi-select) ----
  assign k7 = g2[r_i][c_i].sub.sat[s_i][1];
  assign k8 = g2[0][0].sub.v;
endmodule
