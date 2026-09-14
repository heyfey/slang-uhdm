// r11u33 grid arm g2_site33 — THE SITE, for three fixed bound shapes.
//
// One bound shape per column (`_nu` a bare `int unsigned` parameter, `_add`
// an `A+B` of two of them, `_sub` an `A-1`), written at every site a range
// bound can sit at inside a module: a PORT, a body VARIABLE (packed and
// unpacked), a NET, a TYPEDEF, a struct MEMBER of a typedef, the declared
// type of a LOCALPARAM, and a function's local.
package g2pk33;
  parameter int unsigned PU = 4;
endpackage

module g2_site33 #(
    parameter int unsigned NU = 5,
    parameter int unsigned MU = 3
) (
    input  logic            clk,
    input  logic [NU:0]     i_nu,      // PORT, bare name
    input  logic [NU+MU:0]  i_add,     // PORT, add
    input  logic [NU-1:0]   i_sub,     // PORT, sub
    output logic [NU:0]     o_nu
);
  // body VARIABLE, packed
  logic [NU:0]    v_nu;
  logic [NU+MU:0] v_add;
  logic [NU-1:0]  v_sub;

  // body VARIABLE, unpacked RANGE dim
  logic a_nu  [NU:1];
  logic a_add [NU+MU:1];
  logic a_sub [NU-1:1];

  // body VARIABLE, unpacked SIZE dim
  logic z_nu  [NU];
  logic z_add [NU+MU];
  logic z_sub [NU-1];

  // body NET
  wire [NU:0]    w_nu;
  wire [NU+MU:0] w_add;
  wire [NU-1:0]  w_sub;

  // TYPEDEF packed dims
  typedef logic [NU:0]    t_nu;
  typedef logic [NU+MU:0] t_add;
  typedef logic [NU-1:0]  t_sub;
  t_nu  y_nu;
  t_add y_add;
  t_sub y_sub;

  // struct MEMBER dims of a body typedef
  typedef struct packed {
    logic [NU:0]    m_nu;
    logic [NU+MU:0] m_add;
    logic [NU-1:0]  m_sub;
  } t_st;
  t_st y_st;

  // a LOCALPARAM's declared type
  localparam logic [NU:0]    c_nu  = 1;
  localparam logic [NU+MU:0] c_add = 1;
  localparam logic [NU-1:0]  c_sub = 1;

  // a package parameter, qualified and wildcard-bare
  import g2pk33::*;
  logic [g2pk33::PU:0] v_qual;
  logic [PU:0]         v_bare;
  logic b_qual [g2pk33::PU:1];
  logic b_bare [PU:1];

  assign w_nu = '0;
  assign w_add = '0;
  assign w_sub = '0;
  assign o_nu = v_nu;

  function automatic int f33(input int x);
    logic [NU:0]    f_nu;
    logic [NU+MU:0] f_add;
    logic f_arr [NU:1];
    f_nu = '0; f_add = '0; f_arr[NU] = 1'b0;
    return x;
  endfunction
endmodule
