// r10earl61 GRID B — WHAT the gen-scope high_conn operand names, and WHERE the
// gen scope has to sit.  Every arm is an OPERATION high_conn (`~x` / `x & y`)
// so the top-level bare-ref binder (bind_net_) is out of the picture.
package p61;
  parameter int PW = 3;
  typedef enum logic [1:0] { E0 = 2'd0, E1 = 2'd1 } e61_t;
endpackage

module k61 (input logic a, output logic y);
  assign y = a;
endmodule

// B1: operand names a signal declared INSIDE the same gen scope
module m_loc61 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic yo;
  if (EN) begin : gen_l
    logic gl, gm;
    assign gl = clk;
    assign gm = ~clk;
    k61 i_loc (.a(gl & gm), .y(yo));
  end
  assign q = yo;
endmodule

// B2: operand names a MODULE parameter / a PACKAGE parameter / an ENUM const
module m_par61 (input logic clk, output logic q);
  parameter bit EN = 1;
  parameter logic MP = 1'b1;
  import p61::*;
  logic yo, y2, y3;
  if (EN) begin : gen_p
    k61 i_mp  (.a(clk & MP),            .y(yo));
    k61 i_pp  (.a(clk & (p61::PW > 2)), .y(y2));
    k61 i_en  (.a(clk & (E1 == E1)),    .y(y3));
  end
  assign q = yo ^ y2 ^ y3;
endmodule

// B3: the gen scope is an ANCESTOR but not the immediate parent -- the
// instantiation itself sits at MODULE scope inside a module instantiated in a
// generate block.  Must still BIND (the parent instance is a module instance).
module m_inner61 (input logic clk, output logic q);
  logic yo;
  k61 i_in (.a(~clk), .y(yo));
  assign q = yo;
endmodule
module m_anc61 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic yq;
  if (EN) begin : gen_a
    m_inner61 i_sub (.clk(clk), .q(yq));
  end
  assign q = yq;
endmodule

// B4: gen scope with THREE instances of the same child + an instance ARRAY
module m_multi61 (input logic clk, input logic [2:0] d, output logic q);
  parameter bit EN = 1;
  logic y1,y2,y3;
  logic [2:0] ya;
  if (EN) begin : gen_m
    k61 i_a (.a(~clk),   .y(y1));
    k61 i_b (.a(~clk),   .y(y2));
    k61 i_c (.a(~clk),   .y(y3));
    k61 i_arr [2:0] (.a(~d), .y(ya));
  end
  assign q = y1 ^ y2 ^ y3 ^ ya[0];
endmodule

// B5: EVERY port direction, and an operand that is a parent PORT vs a var vs a
// net, inside a gen scope
module k5_61 (input logic pi, output logic po, inout wire pio);
  assign po = pi;
endmodule
module m_dir61 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic  vv;
  wire   ww;
  logic  yo;
  if (EN) begin : gen_d
    k5_61 i_d (.pi(~clk), .po(yo), .pio(ww));
  end
  assign vv = clk;
  assign q = yo;
endmodule

// B6: HIERARCHICAL reference operand inside a gen scope
module m_hier61 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic yo;
  m_inner61 i_h (.clk(clk), .q());
  if (EN) begin : gen_h
    k61 i_hh (.a(~i_h.q), .y(yo));
  end
  assign q = yo;
endmodule

module g2_earl61 (input logic clk, input logic [2:0] d, output logic o1,o2,o3,o4,o5,o6);
  m_loc61   u1 (.clk(clk), .q(o1));
  m_par61   u2 (.clk(clk), .q(o2));
  m_anc61   u3 (.clk(clk), .q(o3));
  m_multi61 u4 (.clk(clk), .d(d), .q(o4));
  m_dir61   u5 (.clk(clk), .q(o5));
  m_hier61  u6 (.clk(clk), .q(o6));
endmodule
