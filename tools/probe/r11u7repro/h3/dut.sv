// r11u7 grid h3 — an OUT-OF-ORDER named pattern and an inner POSITIONAL one.
package q3;
  typedef struct packed { int unsigned A; int unsigned B; } two_t;
  typedef struct packed { two_t T; int unsigned S; } nest_t;
  localparam nest_t OOO = '{S: 9, T: '{A: 1, B: 2}};   // keys out of order
  localparam nest_t INP = '{T: '{3, 4}, S: 9};         // inner POSITIONAL
endpackage
interface ioo #(parameter q3::nest_t O = q3::OOO); logic d; endinterface
interface iip #(parameter q3::nest_t P = q3::INP); logic d; endinterface
module lo (ioo p); logic z; assign z = p.d; endmodule
module li (iip p); logic z; assign z = p.d; endmodule
module top;
  ioo uo(); iip ui();
  lo o0 (.p(uo));
  li i0 (.p(ui));
endmodule
