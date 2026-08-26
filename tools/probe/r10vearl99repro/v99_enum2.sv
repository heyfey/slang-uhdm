// r10v99 -- what encoding does GOLDEN give an ENUM-CONSTANT member value of a
// FLATTENED (cont_assign) pattern, per written form of the enum member?
package pf2;
  typedef enum logic [5:0] { Eb = 6'b000111, Eh = 6'h5, Ed = 6'd3, Ei, Eu = 9 } e6_t;
  typedef struct packed { logic [3:0] w4; e6_t en; logic [7:0] w8; } s_t;
endpackage
module e2sub (input logic s, input logic [7:0] d, input pf2::s_t din,
              output pf2::s_t ob, output pf2::s_t oh, output pf2::s_t od,
              output pf2::s_t oi, output pf2::s_t ou,
              output pf2::s_t tb, output pf2::s_t th, output pf2::s_t ti);
  assign ob = '{ w4 : '1, en : pf2::Eb, w8 : d };
  assign oh = '{ w4 : '1, en : pf2::Eh, w8 : d };
  assign od = '{ w4 : '1, en : pf2::Ed, w8 : d };
  assign oi = '{ w4 : '1, en : pf2::Ei, w8 : d };
  assign ou = '{ w4 : '1, en : pf2::Eu, w8 : d };
  assign tb = s ? din : '{ w4 : '1, en : pf2::Eb, w8 : '1 };
  assign th = s ? din : '{ w4 : '1, en : pf2::Eh, w8 : '1 };
  assign ti = s ? din : '{ w4 : '1, en : pf2::Ei, w8 : '1 };
endmodule
module v99_enum2 (input logic s, input logic [7:0] d, input pf2::s_t din,
                  output pf2::s_t ob, output pf2::s_t oh, output pf2::s_t od,
                  output pf2::s_t oi, output pf2::s_t ou,
                  output pf2::s_t tb, output pf2::s_t th, output pf2::s_t ti);
  e2sub u (.*);
endmodule
