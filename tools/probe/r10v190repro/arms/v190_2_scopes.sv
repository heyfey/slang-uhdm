// r10v190 arm 2 — WHERE THE ENUM-BASE TYPEDEF LIVES.
// Homes the implementer's grid did not compile: an INTERFACE, a PROGRAM, a
// GENERATE block, a PARAMETERIZED class (whose parameter is specialised), a
// nested class, and a typedef whose own base is ANOTHER typedef (an alias
// chain).  Also a `localparam` in a module (override-able vs final axis) and a
// parameter that is READ nowhere else (unconsumed).
interface iv2_190 #(parameter integer IW = 6) ();
  typedef bit [IW-1 : 0] ti2;
  typedef enum ti2 { i2_a = 0, i2_b = 1 } ei2;        // interface home
  ei2 sig;
endinterface

package pv2_190;
  parameter integer CW = 11;
  parameter integer UNCONSUMED = 33;                   // read by nothing
  typedef bit [CW-1 : 0] tbase2;
  typedef tbase2 talias2;                              // alias chain
  typedef enum talias2 { c2_a = 0, c2_b = 1 } ealias2;

  class Cp2 #(parameter integer GW = 4);
    typedef bit [GW-1 : 0] tg2;
    typedef enum tg2 { g2_a = 0, g2_b = 1 } eg2;       // class-parameter home
    tg2 gv;
    class Inner2;
      localparam integer NW = 3;
      typedef logic [NW : 0] tn2;
      typedef enum tn2 { n2_a = 0, n2_b = 1 } en2;     // nested class home
      tn2 nv;
    endclass
  endclass
endpackage

program prg2_190 ();
  parameter integer RW = 8;
  typedef bit [RW-1 : 0] tr2;
  typedef enum tr2 { r2_a = 0, r2_b = 1 } er2;         // program home
  er2 rv;
  initial rv = r2_b;
endprogram

module v190_2_scopes (input logic clk);
  localparam integer MLW = 10;                         // FINAL (localparam)
  typedef bit [MLW-1 : 0] tm2;
  typedef enum tm2 { m2_a = 0, m2_b = 1 } em2;
  em2 mv;

  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gblk
      localparam integer GLW = 4 + gi;
      typedef bit [GLW-1 : 0] tgn2;
      typedef enum tgn2 { gn2_a = 0, gn2_b = 1 } egn2; // generate-scope home
      egn2 gv;
      always_comb gv = gn2_b;
    end
  endgenerate

  iv2_190 #(.IW(17)) u_if ();
  pv2_190::ealias2  av;
  pv2_190::Cp2#(6)::eg2 cv;
  pv2_190::Cp2#(6)::Inner2::en2 nv;
  always_comb begin
    mv = m2_b;
    av = pv2_190::c2_b;
    cv = pv2_190::Cp2#(6)::g2_b;
    nv = pv2_190::Cp2#(6)::Inner2::n2_b;
  end
endmodule
