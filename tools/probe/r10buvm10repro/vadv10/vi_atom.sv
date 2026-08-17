// verifier arm I -- SCALAR (no range) chains and INTEGER-ATOM chains at the
// enum-base position, plus a signed chain.
package pi10;
  typedef bit            ti_s0;
  typedef ti_s0          ti_s1;
  typedef logic          ti_l0;
  typedef ti_l0          ti_l1;
  typedef int            ti_i0;
  typedef ti_i0          ti_i1;
  typedef byte           ti_y0;
  typedef ti_y0          ti_y1;
  typedef integer        ti_g0;
  typedef ti_g0          ti_g1;
  typedef time           ti_t0;
  typedef ti_t0          ti_t1;
  typedef bit signed [7:0] ti_sg0;
  typedef ti_sg0           ti_sg1;

  typedef enum ti_s0  { A0 = 0, A1 = 1 } e_s0;
  typedef enum ti_s1  { B0 = 0, B1 = 1 } e_s1;
  typedef enum ti_l0  { C0 = 0, C1 = 1 } e_l0;
  typedef enum ti_l1  { D0 = 0, D1 = 1 } e_l1;
  typedef enum ti_i0  { E0 = 0, E1 = 1 } e_i0;
  typedef enum ti_i1  { F0 = 0, F1 = 1 } e_i1;
  typedef enum ti_y0  { G0 = 0, G1 = 1 } e_y0;
  typedef enum ti_y1  { H0 = 0, H1 = 1 } e_y1;
  typedef enum ti_g0  { I0 = 0, I1 = 1 } e_g0;
  typedef enum ti_g1  { J0 = 0, J1 = 1 } e_g1;
  typedef enum ti_t0  { K0 = 0, K1 = 1 } e_t0;
  typedef enum ti_t1  { L0 = 0, L1 = 1 } e_t1;
  typedef enum ti_sg0 { M0 = 0, M1 = 1 } e_sg0;
  typedef enum ti_sg1 { N0 = 0, N1 = 1 } e_sg1;
endpackage
module viTop10;
  pi10::e_s0 a0; pi10::e_s1 a1; pi10::e_l0 a2; pi10::e_l1 a3;
  pi10::e_i0 a4; pi10::e_i1 a5; pi10::e_y0 a6; pi10::e_y1 a7;
  pi10::e_g0 a8; pi10::e_g1 a9; pi10::e_t0 b0; pi10::e_t1 b1;
  pi10::e_sg0 b2; pi10::e_sg1 b3;
endmodule
