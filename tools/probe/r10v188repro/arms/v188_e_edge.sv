// r10v188repro/arms/v188_e_edge.sv — ADVERSARIAL WIDTH-CHANGING SHAPES.
// Shift magnitudes at the model's boundaries, a right shift past the left
// operand's own width (a NEGATIVE modelled size), an unsized based literal in
// every operand position, a 64-bit sized leaf, and mixed sized/unsized
// arithmetic where the ENCODING discriminator (A's own type) can be read off.
package v188e_pkg;
  typedef enum longint unsigned {
    E_S1   = 64'd1 << 1,
    E_S31  = 64'd1 << 31,
    E_S32  = 64'd1 << 32,
    E_S62  = 64'd1 << 62,
    E_R1   = 64'd2048 >> 1,
    E_R9   = 8'hFF >> 9,
    E_R7   = 8'hFF >> 7,
    E_U0   = 'h1 << 12,
    E_U1   = 'h1 + 'h7,
    E_U2   = 'h3 + 40,
    E_U3   = 40 + 'h4,
    E_U4   = 'h5 - 'h1,
    E_M0   = 3'h2 + 3'h1,
    E_M1   = 8'h10 + 16'h1,
    E_M2   = 16'h2 + 8'h10,
    E_D0   = 1 << 2 << 3 << 4,
    E_D1   = 1 + 2 + 3 + 4 + 5 + 6 + 7 + 8 + 9 + 11,
    E_B0   = 4'hF * 4'h3,
    E_B1   = 100 / 7,
    E_B2   = 1000 - 1
  } v188e_e;
endpackage
