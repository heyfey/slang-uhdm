// r11v55 VERIFIER arm — adjustSize WITH THE SHARING CONFOUND REMOVED.
// `ve6_adjust_table` reads EACH member from THREE Lhs of different widths, so
// every non-uniquifying encoding (Hex, Bin, Dec) measures golden's LAST writer,
// not adjustSize.  Here each member is read EXACTLY ONCE, by exactly one Lhs,
// so the cell reads adjustSize itself.  Three copies of the struct give the
// narrow / equal / wide directions without any member being read twice.
package p;
  typedef struct packed {
    int unsigned u;
    logic [15:0] h;
    logic [15:0] b;
    logic [15:0] d;
  } cfg_t;
  localparam cfg_t LIT = '{u: 300, h: 16'hBEEF, b: 16'b1010_0101_1100_0011, d: 16'd4660};
endpackage
module nar #(parameter p::cfg_t C = p::LIT)
           (output logic [7:0] u_o, output logic [7:0] h_o,
            output logic [7:0] b_o, output logic [7:0] d_o);
  assign u_o = C.u;  assign h_o = C.h;  assign b_o = C.b;  assign d_o = C.d;
endmodule
module eq_ #(parameter p::cfg_t C = p::LIT)
           (output logic [31:0] u_o, output logic [15:0] h_o,
            output logic [15:0] b_o, output logic [15:0] d_o);
  assign u_o = C.u;  assign h_o = C.h;  assign b_o = C.b;  assign d_o = C.d;
endmodule
module wid #(parameter p::cfg_t C = p::LIT)
           (output logic [63:0] u_o, output logic [31:0] h_o,
            output logic [31:0] b_o, output logic [31:0] d_o);
  assign u_o = C.u;  assign h_o = C.h;  assign b_o = C.b;  assign d_o = C.d;
endmodule
module dut (output logic [7:0]  n_u, output logic [7:0]  n_h,
            output logic [7:0]  n_b, output logic [7:0]  n_d,
            output logic [31:0] e_u, output logic [15:0] e_h,
            output logic [15:0] e_b, output logic [15:0] e_d,
            output logic [63:0] w_u, output logic [31:0] w_h,
            output logic [31:0] w_b, output logic [31:0] w_d);
  nar u_n (.u_o(n_u), .h_o(n_h), .b_o(n_b), .d_o(n_d));
  eq_ u_e (.u_o(e_u), .h_o(e_h), .b_o(e_b), .d_o(e_d));
  wid u_w (.u_o(w_u), .h_o(w_h), .b_o(w_b), .d_o(w_d));
endmodule
