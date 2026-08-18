// r10v61 ADVERSARIAL GRID 2 — law A: interface / modport / program /
// interface-internal generate, and 1..3 instances of the same child.
interface iv61 (input logic clk);
  logic req, gnt;
  modport mp (input req, output gnt);
  // a generate block INSIDE an interface body (cont_assign carrier)
  parameter bit EN = 1;
  logic ii;
  if (EN) begin : gen_if_i
    logic il;
    assign il = clk;
    assign ii = il & req;
  end
endinterface

module kv61 (input logic a, output logic y);
  assign y = a;
endmodule
module kif61 (iv61.mp p, input logic a, output logic y);
  assign y = a & p.req;
endmodule
module kfull61 (iv61 b, input logic a, output logic y);
  assign y = a & b.req;
endmodule

// B1: interface / modport port connections inside a generate block
module m_b1 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic v, y1, y2;
  iv61 bus (.clk(clk));
  if (EN) begin : gen_ifc
    kif61 i_mp (.p(bus.mp), .a(v & clk), .y(y1));
    kfull61 i_fu (.b(bus),  .a(v | clk), .y(y2));
  end
  assign q = y1 ^ y2;
endmodule

// B2: 1, 2, 3 instances of the SAME child in one gen scope with the same
//     operand expression (fold/share pressure)
module m_b2 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic v, u, y1, y2, y3;
  if (EN) begin : gen_n3
    kv61 i_1 (.a(v & u), .y(y1));
    kv61 i_2 (.a(v & u), .y(y2));
    kv61 i_3 (.a(v & u), .y(y3));
  end
  assign q = y1 ^ y2 ^ y3;
endmodule

// B3: instance ARRAY at MODULE scope (control) and in a gen scope
module kv4 (input logic [3:0] a, output logic [3:0] y);
  assign y = a;
endmodule
module m_b3 (input logic clk, input logic [3:0] d, output logic q);
  parameter bit EN = 1;
  logic [3:0] ym, yg;
  logic [3:0] mv;
  kv61 i_am [3:0] (.a(mv & d), .y(ym));
  if (EN) begin : gen_ar
    kv61 i_ag [3:0] (.a(mv & d), .y(yg));
  end
  assign q = ym[0] ^ yg[0];
endmodule

// B4: generate inside a module inside a generate (parent-instance chain)
module m_inner (input logic clk, output logic q);
  parameter bit EN = 1;
  logic mv, yo;
  assign mv = clk;
  if (EN) begin : gi
    kv61 i_x (.a(mv & clk), .y(yo));
  end
  assign q = yo;
endmodule
module m_b4 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic yq;
  if (EN) begin : go
    m_inner i_sub (.clk(clk), .q(yq));
  end
  assign q = yq;
endmodule

// B5: gen scope inside a module with a port operand of every direction
module k3 (input logic pi, output logic po, inout wire pio);
  assign po = pi;
endmodule
module m_b5 (input logic pin, output logic pout, inout wire pinout);
  parameter bit EN = 1;
  logic yo;
  wire  ww;
  if (EN) begin : gen_p
    k3 i_p (.pi(pin & 1'b1), .po(yo), .pio(ww));
  end
  assign pout = yo;
endmodule

module v2_v61 (input logic clk, input logic [3:0] d, output logic o);
  logic o1,o2,o3,o4,o5;
  wire  wio;
  m_b1 u1 (.clk(clk), .q(o1));
  m_b2 u2 (.clk(clk), .q(o2));
  m_b3 u3 (.clk(clk), .d(d), .q(o3));
  m_b4 u4 (.clk(clk), .q(o4));
  m_b5 u5 (.pin(clk), .pout(o5), .pinout(wio));
  assign o = o1 ^ o2 ^ o3 ^ o4 ^ o5;
endmodule
