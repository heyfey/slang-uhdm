// r10earl30 arm g3_base.sv — AXIS (d): the ENUM BASE TYPE.  Origin and context
// are both held at the witness's (a PACKAGE enum literal as the right operand of
// `==`); only the enum's base type varies.  dm::cmderr_e is `logic [2:0]`, so
// b1 is the witness cell and everything else is a candidate discriminator.
package p3;
  typedef enum logic [2:0]        { A0, A1 } a_t;  // b1 THE WITNESS BASE
  typedef enum logic [7:0]        { B0, B1 } b_t;  // b2 wider unsigned vector
  typedef enum logic signed [2:0] { C0, C1 } c_t;  // b3 SIGNED vector base
  typedef enum bit [1:0]          { D0, D1 } d_t;  // b4 bit base
  typedef enum int                { F0, F1 } f_t;  // b5 int base (signed, 32)
  typedef enum                    { G0, G1 } g_t;  // b6 NO base -> int
  typedef enum byte               { H0, H1 } h_t;  // b7 byte base (signed, 8)
  typedef enum logic [2:0]        { I0 = 3'd0, I1 = 3'd1 } i_t;  // b8 EXPLICIT sized init
  typedef enum logic [2:0]        { J0 = 0,    J1 = 1    } j_t;  // b9 EXPLICIT unsized init
endpackage

module g3_base (input logic [31:0] q, output logic [17:0] o);
  logic [17:0] r;
  always_comb begin
    r = 18'd0;
    if (q == p3::A0) r[0]  = 1'b1;   // b1 zero member
    if (q == p3::A1) r[1]  = 1'b1;   // b1 nonzero member
    if (q == p3::B0) r[2]  = 1'b1;
    if (q == p3::B1) r[3]  = 1'b1;
    if (q == p3::C0) r[4]  = 1'b1;
    if (q == p3::C1) r[5]  = 1'b1;
    if (q == p3::D0) r[6]  = 1'b1;
    if (q == p3::D1) r[7]  = 1'b1;
    if (q == p3::F0) r[8]  = 1'b1;
    if (q == p3::F1) r[9]  = 1'b1;
    if (q == p3::G0) r[10] = 1'b1;
    if (q == p3::G1) r[11] = 1'b1;
    if (q == p3::H0) r[12] = 1'b1;
    if (q == p3::H1) r[13] = 1'b1;
    if (q == p3::I0) r[14] = 1'b1;
    if (q == p3::I1) r[15] = 1'b1;
    if (q == p3::J0) r[16] = 1'b1;
    if (q == p3::J1) r[17] = 1'b1;
  end
  assign o = r;
endmodule
