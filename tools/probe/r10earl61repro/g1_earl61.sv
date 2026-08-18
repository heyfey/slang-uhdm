// r10earl61 GRID A — port HighConn expression shapes x scope nesting.
// One leaf child with one INPUT port; the actual is varied over every shape the
// brief names, at module scope / inside if-generate / for-generate / nested gen.
module k61 (input logic a, output logic y);
  assign y = a;
endmodule

function automatic logic f61(input logic x);
  return ~x;
endfunction

// ---------------- module scope ----------------
module m_mod61 (input logic clk, input logic [3:0] d, output logic q);
  logic       v, u, sel;
  wire        nw;
  logic [3:0] vv;
  logic y1,y2,y3,y4,y5,y6,y7,y8,y9,y10;
  k61 i_bare (.a(clk),            .y(y1));
  k61 i_not  (.a(~clk),           .y(y2));
  k61 i_and  (.a(v & u),          .y(y3));
  k61 i_cat  (.a({v, u}),         .y(y4));
  k61 i_bit  (.a(vv[0]),          .y(y5));
  k61 i_prt  (.a(|vv[1:0]),       .y(y6));
  k61 i_call (.a(f61(v)),         .y(y7));
  k61 i_tern (.a(sel ? v : u),    .y(y8));
  k61 i_cst  (.a(1'b0),           .y(y9));
  k61 i_net  (.a(~nw),            .y(y10));
  assign q = y1;
endmodule

// ---------------- if-generate ----------------
module m_if61 (input logic clk, input logic [3:0] d, output logic q);
  parameter bit EN = 1;
  logic       v, u, sel;
  wire        nw;
  logic [3:0] vv;
  logic y1,y2,y3,y4,y5,y6,y7,y8,y9,y10;
  if (EN) begin : gen_if
    k61 i_bare (.a(clk),          .y(y1));
    k61 i_not  (.a(~clk),         .y(y2));
    k61 i_and  (.a(v & u),        .y(y3));
    k61 i_cat  (.a({v, u}),       .y(y4));
    k61 i_bit  (.a(vv[0]),        .y(y5));
    k61 i_prt  (.a(|vv[1:0]),     .y(y6));
    k61 i_call (.a(f61(v)),       .y(y7));
    k61 i_tern (.a(sel ? v : u),  .y(y8));
    k61 i_cst  (.a(1'b0),         .y(y9));
    k61 i_net  (.a(~nw),          .y(y10));
  end
  assign q = y1;
endmodule

// ---------------- for-generate ----------------
module m_for61 (input logic clk, input logic [3:0] d, output logic q);
  logic       v, u, sel;
  logic [3:0] vv;
  logic [1:0] y2a, y3a;
  for (genvar gi = 0; gi < 2; gi++) begin : gen_for
    k61 i_not (.a(~clk),          .y(y2a[gi]));
    k61 i_and (.a(vv[gi] & u),    .y(y3a[gi]));
  end
  assign q = y2a[0];
endmodule

// ---------------- nested generate ----------------
module m_nest61 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic v, u;
  logic yq1, yq2;
  if (EN) begin : gen_o
    if (EN) begin : gen_i
      k61 i_not (.a(~clk),        .y(yq1));
      k61 i_and (.a(v & u),       .y(yq2));
    end
  end
  assign q = yq1;
endmodule

module g1_earl61 (input logic clk, input logic [3:0] d, output logic q1,q2,q3,q4);
  m_mod61  u1 (.clk(clk), .d(d), .q(q1));
  m_if61   u2 (.clk(clk), .d(d), .q(q2));
  m_for61  u3 (.clk(clk), .d(d), .q(q3));
  m_nest61 u4 (.clk(clk), .q(q4));
endmodule
