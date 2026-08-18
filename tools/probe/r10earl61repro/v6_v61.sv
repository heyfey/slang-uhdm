// r10v61 ADVERSARIAL GRID 6 — law A: ORDERED (positional) connections, gates /
// primitives in a gen scope, $unit-scope operands, function-call arguments that
// are gen-locals, unconnected ports, and a defparam-free parameterised child.
logic uv61;              // $unit-scope signal (--single-unit)
parameter int UP61 = 3;  // $unit-scope parameter

module kv61 (input logic a, output logic y);
  assign y = a;
endmodule
module kv2 (input logic a, input logic b, output logic y);
  assign y = a & b;
endmodule
function automatic logic fv61(input logic x); return ~x; endfunction

// F1: ORDERED (positional) port connections inside a gen scope
module m_f1 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic v, u, yo;
  if (EN) begin : gp
    kv2 i_ord (v & u, ~clk, yo);
  end
  assign q = yo;
endmodule

// F2: gate primitive instantiation inside a gen scope
module m_f2 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic v, u, yo, yp;
  if (EN) begin : gg
    and  g_and (yo, v, u);
    buf  g_buf (yp, clk);
  end
  assign q = yo ^ yp;
endmodule

// F3: $unit-scope signal and parameter as gen-scope high_conn operands
module m_f3 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic yo, yp;
  if (EN) begin : gu
    kv61 i_us (.a(uv61 & clk),          .y(yo));
    kv61 i_up (.a(clk & (UP61 > 2)),    .y(yp));
  end
  assign q = yo ^ yp;
endmodule

// F4: function call whose ARGUMENT is a gen-local vs a module signal
module m_f4 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic mv, yo, yp;
  if (EN) begin : gf
    logic gl;
    assign gl = clk;
    kv61 i_fg (.a(fv61(gl)), .y(yo));
    kv61 i_fm (.a(fv61(mv)), .y(yp));
  end
  assign q = yo ^ yp;
endmodule

// F5: UNCONNECTED port and an empty () actual in a gen scope
module m_f5 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic v, u, yo;
  if (EN) begin : ge
    kv2 i_uc (.a(v & u), .b(), .y(yo));
  end
  assign q = yo;
endmodule

// F6: parameterised child with a gen-scope operand
module kp61 #(parameter int W = 1) (input logic [W-1:0] a, output logic y);
  assign y = |a;
endmodule
module m_f6 (input logic clk, input logic [3:0] d, output logic q);
  parameter bit EN = 1;
  logic [3:0] mw;
  logic yo;
  if (EN) begin : gpr
    kp61 #(.W(4)) i_p (.a(mw & d), .y(yo));
  end
  assign q = yo;
endmodule

module v6_v61 (input logic clk, input logic [3:0] d, output logic o);
  logic o1,o2,o3,o4,o5,o6;
  m_f1 u1 (.clk(clk), .q(o1));
  m_f2 u2 (.clk(clk), .q(o2));
  m_f3 u3 (.clk(clk), .q(o3));
  m_f4 u4 (.clk(clk), .q(o4));
  m_f5 u5 (.clk(clk), .q(o5));
  m_f6 u6 (.clk(clk), .d(d), .q(o6));
  assign o = o1^o2^o3^o4^o5^o6;
endmodule
