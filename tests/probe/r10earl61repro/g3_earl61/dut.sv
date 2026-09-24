// r10earl61 GRID C — WHERE the operand's declaration has to live for a
// gen-scope port HighConn operand to bind.  B1 showed a SAME-gen-scope local
// binds; these arms cut the scope axis finely.
module k61 (input logic a, output logic y);
  assign y = a;
endmodule

// C1: nested gen -- inner instance, operand declared in the OUTER gen block
module m_c1 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic yo, yp;
  if (EN) begin : gen_o
    logic ol, om;
    assign ol = clk;
    assign om = ~clk;
    if (EN) begin : gen_i
      logic il;
      assign il = clk;
      k61 i_outer (.a(ol & om), .y(yo));   // names OUTER gen locals
      k61 i_inner (.a(il & il), .y(yp));   // names its OWN gen locals
    end
  end
  assign q = yo ^ yp;
endmodule

// C2: for-generate locals, and the genvar
module m_c2 (input logic clk, output logic q);
  logic [1:0] ya, yb;
  for (genvar gi = 0; gi < 2; gi++) begin : gf
    logic fl;
    assign fl = clk;
    k61 i_loc (.a(fl & fl),  .y(ya[gi]));
    k61 i_mix (.a(fl & clk), .y(yb[gi]));   // one gen-local, one module signal
  end
  assign q = ya[0] ^ yb[0];
endmodule

// C3: a begin/end block INSIDE the gen block (a nested unnamed scope)
module m_c3 (input logic clk, output logic q);
  parameter bit EN = 1;
  logic yo;
  if (EN) begin : gen_b
    logic bl;
    assign bl = clk;
    if (1) begin : gen_bb
      k61 i_bb (.a(bl & bl), .y(yo));      // outer-gen local from a nested gen
    end
  end
  assign q = yo;
endmodule

// C4: module scope reference to a signal declared in a gen block is illegal,
// so instead: MODULE-scope instance whose operand names a module signal -- the
// control that must keep binding.
module m_c4 (input logic clk, output logic q);
  logic ml, yo;
  assign ml = clk;
  k61 i_m (.a(ml & clk), .y(yo));
  assign q = yo;
endmodule

module g3_earl61 (input logic clk, output logic o1,o2,o3,o4);
  m_c1 u1 (.clk(clk), .q(o1));
  m_c2 u2 (.clk(clk), .q(o2));
  m_c3 u3 (.clk(clk), .q(o3));
  m_c4 u4 (.clk(clk), .q(o4));
endmodule
