// r11u7 grid h2 — MIXED member kinds: which member comes FIRST decides.
package q2;
  typedef struct packed { int unsigned DAT; } bus_t;
  typedef struct packed { int unsigned SCA; bus_t BUS; } fs_t;  // scalar FIRST
  typedef struct packed { bus_t BUS; int unsigned SCA; } sf_t;  // struct FIRST
  localparam fs_t FSD = '{SCA: 5, BUS: '{DAT: 32}};
  localparam sf_t SFD = '{BUS: '{DAT: 32}, SCA: 5};
endpackage
interface ifs #(parameter q2::fs_t F = q2::FSD); logic d; endinterface
interface isf #(parameter q2::sf_t S = q2::SFD); logic d; endinterface
module lf (ifs p); logic z; assign z = p.d; endmodule
module ls (isf p); logic z; assign z = p.d; endmodule
module top;
  ifs uf(); isf us();
  lf f0 (.p(uf));
  ls s0 (.p(us));
endmodule
