// r11u3 grid g2 — the ENCODING MATRIX of a struct-parameter MEMBER SELECT used
// as an instance parameter override actual: (member kind/width) x (formal type).
package p;
  typedef enum logic [1:0] { A2 = 2'b01 } e2_t;
  typedef enum int         { AI = 32'd5 } ei_t;
  typedef struct packed {
    e2_t        m_e2;   // 2  bits, enum over logic[1:0]
    logic [3:0] m_v4;   // 4  bits
    logic       m_b1;   // 1  bit
    ei_t        m_ei;   // 32 bits, enum over int
    logic [7:0] m_v8;   // 8  bits
  } s_t;
endpackage

module f_int   (output int o);          parameter int         P = 0; assign o = P;      endmodule
module f_l4    (output logic [3:0] o);  parameter logic [3:0] P = 0; assign o = P;      endmodule
module f_l2    (output logic [1:0] o);  parameter logic [1:0] P = 0; assign o = P;      endmodule
module f_e2    (output logic [1:0] o);  parameter p::e2_t     P = 0; assign o = P;      endmodule
module f_ei    (output int o);          parameter p::ei_t     P = 0; assign o = P;      endmodule
module f_none  (output int o);          parameter             P = 0; assign o = P;      endmodule
module f_b1    (output logic o);        parameter bit         P = 0; assign o = P;      endmodule
module f_l32   (output logic [31:0] o); parameter logic [31:0] P = 0; assign o = P;     endmodule

module top;
  import p::*;
  parameter s_t C = 47'b01_1010_1_00000000000000000000000000000101_11001100;
  int   oa, ob, oc, od, oe, of_, og, oh, oi, oj;
  logic [3:0]  pa, pb;
  logic [1:0]  qa, qb, qc;
  logic        ra;
  logic [31:0] sa, sb;

  f_int   u_int_e2 (.o(oa));  defparam u_int_e2.P  = 0;   // placeholder, unused
  // member x formal matrix (named overrides)
  f_int  #(.P(C.m_e2)) i_int_e2 (.o(ob));
  f_int  #(.P(C.m_v4)) i_int_v4 (.o(oc));
  f_int  #(.P(C.m_b1)) i_int_b1 (.o(od));
  f_int  #(.P(C.m_ei)) i_int_ei (.o(oe));
  f_int  #(.P(C.m_v8)) i_int_v8 (.o(of_));
  f_l4   #(.P(C.m_e2)) i_l4_e2  (.o(pa));
  f_l4   #(.P(C.m_v4)) i_l4_v4  (.o(pb));
  f_l2   #(.P(C.m_e2)) i_l2_e2  (.o(qa));
  f_l2   #(.P(C.m_v4)) i_l2_v4  (.o(qb));
  f_e2   #(.P(C.m_e2)) i_e2_e2  (.o(qc));
  f_ei   #(.P(C.m_ei)) i_ei_ei  (.o(og));
  f_none #(.P(C.m_v4)) i_no_v4  (.o(oh));
  f_none #(.P(C.m_ei)) i_no_ei  (.o(oi));
  f_b1   #(.P(C.m_b1)) i_b1_b1  (.o(ra));
  f_l32  #(.P(C.m_ei)) i_l32_ei (.o(sa));
  f_l32  #(.P(C.m_v8)) i_l32_v8 (.o(sb));
  f_int  #(.P(C.m_v4 + 0)) i_int_expr (.o(oj));
endmodule
