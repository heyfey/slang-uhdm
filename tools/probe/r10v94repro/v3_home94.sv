// r10v94 arm v3 -- HOMES: a bind instance, a 3-deep chain, an interface with a
// gen scope, and a module gen scope reading an interface signal.
// MEASUREMENT ONLY.
interface ifv3_94 #(parameter int unsigned W = 8) ();
  logic [W-1:0] sig;
  logic [W-1:0] out;
  assign sig = '0;
  if (W > 2) begin : gi
    logic [W-1:0] il;
    assign il = sig;
    // interface-level signal, interface gen-local, and a parent-scope read
    assign out = W'(sig) ^ W'(il);
  end
endinterface

module chv3_94 #(parameter int unsigned W = 8) (
  input  logic [W-1:0] a_i,
  output logic [W-1:0] y_o
);
  logic [W-1:0] m_var;
  assign m_var = a_i;
  if (W > 2) begin : gen_b
    assign y_o = W'(a_i) ^ W'(m_var);
  end
endmodule

module bnd_94 #(parameter int unsigned W = 8) (
  input logic [W-1:0] a_i, output logic [W-1:0] bo
);
  logic [W-1:0] bm;
  assign bm = a_i;
  if (W > 2) begin : gen_bind
    logic [W-1:0] bl;
    assign bl = a_i;
    assign bo = W'(a_i) ^ W'(bm) ^ W'(bl);
  end
endmodule

module v3_home94_top (
  input logic [7:0] a8,
  output logic [7:0] y1, y2
);
  ifv3_94 #(.W(8)) the_if ();
  chv3_94 #(.W(8)) u_c (.a_i(a8), .y_o(y1));
  assign y2 = the_if.out;
  bind chv3_94 bnd_94 #(.W(W)) u_bnd (.a_i(a_i), .bo());
endmodule
