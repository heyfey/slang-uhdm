// r11u3 grid g3 — the MEMBER-TYPE axis of § structParamMemberOvBinary: a member
// declared as a PREDEFINED INTEGER (int / int unsigned / byte / shortint)
// against the same formals as g2, plus the same members reached through a
// struct parameter whose value comes from a CONSTANT FUNCTION.
package p3;
  typedef enum logic [1:0] { A2 = 2'b01 } e2_t;
  typedef struct packed {
    int unsigned m_iu;    // 32 bits, int_typespec, UNSIGNED
    int          m_is;    // 32 bits, int_typespec, SIGNED
    byte         m_by;    // 8  bits
    shortint     m_sh;    // 16 bits
    logic [3:0]  m_v4;    // 4  bits
    e2_t         m_e2;    // 2  bits
  } s3_t;

  function automatic s3_t mk3();
    s3_t r;
    r.m_iu = 2;
    r.m_is = -3;
    r.m_by = 8'hcc;
    r.m_sh = 16'h00ff;
    r.m_v4 = 4'b1010;
    r.m_e2 = A2;
    return r;
  endfunction
endpackage

module f_iu (output int o); parameter int unsigned P = 0; assign o = P; endmodule
module f_in (output int o); parameter int          P = 0; assign o = P; endmodule
module f_l4 (output logic [3:0] o); parameter logic [3:0] P = 0; assign o = P; endmodule
module f_by (output byte o); parameter byte P = 0; assign o = P; endmodule

module top;
  import p3::*;
  parameter s3_t L = {32'd2, -32'sd3, 8'hcc, 16'h00ff, 4'b1010, 2'b01};  // LITERAL base
  parameter s3_t F = mk3();                                              // FUNCTION base
  int a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12;
  logic [3:0] b1,b2;
  byte c1,c2;

  f_iu #(.P(L.m_iu)) i_iu_iu (.o(a1));
  f_iu #(.P(L.m_is)) i_iu_is (.o(a2));
  f_iu #(.P(L.m_by)) i_iu_by (.o(a3));
  f_iu #(.P(L.m_sh)) i_iu_sh (.o(a4));
  f_iu #(.P(L.m_v4)) i_iu_v4 (.o(a5));
  f_iu #(.P(L.m_e2)) i_iu_e2 (.o(a6));
  f_in #(.P(L.m_iu)) i_in_iu (.o(a7));
  f_in #(.P(L.m_is)) i_in_is (.o(a8));
  f_in #(.P(L.m_by)) i_in_by (.o(a9));
  f_l4 #(.P(L.m_iu)) i_l4_iu (.o(b1));
  f_by #(.P(L.m_by)) i_by_by (.o(c1));

  f_iu #(.P(F.m_iu)) j_iu_iu (.o(a10));
  f_iu #(.P(F.m_is)) j_iu_is (.o(a11));
  f_iu #(.P(F.m_v4)) j_iu_v4 (.o(a12));
  f_l4 #(.P(F.m_v4)) j_l4_v4 (.o(b2));
  f_by #(.P(F.m_by)) j_by_by (.o(c2));
endmodule
