// r10v61 ADVERSARIAL GRID 1 — law A: high_conn shapes x generate scope forms
// the implementer's g1/g2/g3 did NOT cover.
package pv61;
  parameter int PW = 5;
  typedef enum logic [1:0] { EA = 2'd0, EB = 2'd1 } ev61_t;
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } sv61_t;
endpackage

module kv61 (input logic a, output logic y);
  assign y = a;
endmodule
module kw61 (input logic [3:0] a, output logic [3:0] y);
  assign y = a;
endmodule
function automatic logic fv61(input logic x); return ~x; endfunction

// A1: if-generate with NO begin/end (implicit unnamed block)
module m_a1 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic v, u, yo;
  if (EN) kv61 i_nb (.a(v & u), .y(yo));
  assign q = yo;
endmodule

// A2: for-generate with NO begin/end
module m_a2 (input logic clk, output logic q);
  logic v, u;
  logic [1:0] yo;
  for (genvar gi = 0; gi < 2; gi++) kv61 i_nb (.a(v & u), .y(yo[gi]));
  assign q = yo[0];
endmodule

// A3: case-generate
module m_a3 (input logic clk, output logic q);
  parameter int SEL = 1;
  logic v, u, yo;
  case (SEL)
    1: begin : gen_c1
         kv61 i_c (.a(v & u), .y(yo));
       end
    default: begin : gen_cd
         kv61 i_d (.a(v | u), .y(yo));
       end
  endcase
  assign q = yo;
endmodule

// A4: UNNAMED if-generate with begin/end (genblk numbering)
module m_a4 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic v, u, yo;
  if (EN) begin
    kv61 i_un (.a(v & u), .y(yo));
  end
  assign q = yo;
endmodule

// A5: three-deep nested generate; operand from each level
module m_a5 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic mv, yo1, yo2, yo3;
  if (EN) begin : g1
    logic l1;
    assign l1 = clk;
    if (EN) begin : g2
      logic l2;
      assign l2 = clk;
      if (EN) begin : g3
        logic l3;
        assign l3 = clk;
        kv61 i_l3 (.a(l3 & l3), .y(yo1));
        kv61 i_l2 (.a(l2 & l2), .y(yo2));
        kv61 i_l1 (.a(l1 & mv), .y(yo3));
      end
    end
  end
  assign q = yo1 ^ yo2 ^ yo3;
endmodule

// A6: more shapes in a gen scope: replication, cast, sysfunc, ipsel, member,
//     mixed concat, ternary with gen-local condition
module m_a6 (input logic clk, input logic [7:0] d, output logic q);
  parameter bit EN = 1;
  import pv61::*;
  logic v, u;
  logic [7:0] dv;
  sv61_t sv;
  logic [3:0] y1,y2,y3,y4,y5,y6,y7,y8;
  if (EN) begin : gen_s
    logic gl;
    logic [3:0] gw;
    assign gl = clk;
    assign gw = d[3:0];
    kw61 i_rep  (.a({4{v}}),            .y(y1));
    kw61 i_cast (.a(4'(dv)),            .y(y2));
    kw61 i_sys  (.a($bits(dv)),         .y(y3));
    kw61 i_ips  (.a(dv[2 +: 4]),        .y(y4));
    kw61 i_mem  (.a(sv.hi),             .y(y5));
    kw61 i_mix  (.a({gw[1:0], dv[1:0]}),.y(y6));
    kw61 i_tern (.a(gl ? gw : dv[3:0]), .y(y7));
    kw61 i_pkg  (.a({2'b0, PW[1:0]}),   .y(y8));
  end
  assign q = ^{y1,y2,y3,y4,y5,y6,y7,y8};
endmodule

// A7: .name() shorthand and .* wildcard inside a gen scope
module kn61 (input logic clk, input logic v, output logic y);
  assign y = clk & v;
endmodule
module m_a7 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic v, y;
  if (EN) begin : gen_n
    kn61 i_sh (.clk, .v, .y);
  end
  assign q = y;
endmodule
module m_a8 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic v, y;
  if (EN) begin : gen_w
    kn61 i_wc (.*);
  end
  assign q = y;
endmodule

// A9: output/inout port high_conn with a nested ref inside a gen scope
module kio61 (input logic a, output logic [1:0] y, inout wire z);
  assign y = {a,a};
endmodule
module m_a9 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic v, w;
  logic [3:0] yy;
  wire  zz;
  if (EN) begin : gen_io
    kio61 i_io (.a(clk), .y(yy[3:2]), .z(zz));
  end
  assign q = yy[3];
endmodule

// A10: explicit hierarchical operand naming an OUTER gen block's local
module m_a10 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic yo;
  if (EN) begin : go
    logic ol;
    assign ol = clk;
    if (EN) begin : gi
      kv61 i_h (.a(go.ol & clk), .y(yo));
    end
  end
  assign q = yo;
endmodule

// A11: gen-scope operand that is a gen-scope PARAMETER / localparam
module m_a11 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic yo, v;
  if (EN) begin : ga
    localparam bit GP = 1;
    logic la;
    assign la = clk;
    kv61 i_af (.a(la & GP), .y(yo));
  end
  assign q = yo;
endmodule

module v1_v61 (input logic clk, input logic [7:0] d, output logic o);
  logic o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11;
  m_a1  u1  (.clk(clk), .q(o1));
  m_a2  u2  (.clk(clk), .q(o2));
  m_a3  u3  (.clk(clk), .q(o3));
  m_a4  u4  (.clk(clk), .q(o4));
  m_a5  u5  (.clk(clk), .q(o5));
  m_a6  u6  (.clk(clk), .d(d), .q(o6));
  m_a7  u7  (.clk(clk), .q(o7));
  m_a8  u8  (.clk(clk), .q(o8));
  m_a9  u9  (.clk(clk), .q(o9));
  m_a10 u10 (.clk(clk), .q(o10));
  m_a11 u11 (.clk(clk), .q(o11));
  assign o = ^{o1,o2,o3,o4,o5,o6,o7,o8,o9,o10,o11};
endmodule
