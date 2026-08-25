// r10earl94 arm g3 -- the GEN-SCOPE-KIND grid (gen-if / gen-for / gen-case /
// nested / unnamed) crossed with the TARGET-KIND grid (port net / module var /
// module wire / gen-local / parameter / localparam / genvar).  MEASUREMENT ONLY.
module ch3_94 #(parameter int unsigned W = 8, parameter int unsigned SEL = 1) (
  input  logic [W-1:0] a_i,
  output logic [W-1:0] f_o, r_o, c_o, n_o, u_o
);
  localparam int unsigned LP = 3;
  logic [W-1:0] m_var;
  wire  [W-1:0] m_wire = a_i;
  assign m_var = a_i;

  // gen-if, NAMED
  if (W > 2) begin : gen_if
    logic [W-1:0] g_loc;
    assign g_loc = a_i;
    assign f_o = W'(a_i) ^ W'(m_var) ^ W'(m_wire) ^ W'(g_loc) ^ W'(LP);
  end
  // gen-for
  for (genvar gi = 0; gi < 1; gi++) begin : gen_for
    logic [W-1:0] l_loc;
    assign l_loc = a_i;
    assign r_o = W'(a_i) ^ W'(m_var) ^ W'(l_loc) ^ W'(gi);
  end
  // gen-case
  case (SEL)
    1: begin : gen_case
      logic [W-1:0] k_loc;
      assign k_loc = a_i;
      assign c_o = W'(a_i) ^ W'(m_var) ^ W'(k_loc);
    end
    default: begin : gen_case_d
      assign c_o = '0;
    end
  endcase
  // nested gen
  if (W > 2) begin : gen_out
    logic [W-1:0] o_loc;
    assign o_loc = a_i;
    if (W > 3) begin : gen_in
      logic [W-1:0] i_loc;
      assign i_loc = a_i;
      assign n_o = W'(a_i) ^ W'(m_var) ^ W'(o_loc) ^ W'(i_loc);
    end
  end
  // UNNAMED gen-if
  if (W > 2) begin
    assign u_o = W'(a_i) ^ W'(m_var);
  end
endmodule

module g3_kind94_top (
  input logic [7:0] a8, input logic [15:0] a16,
  output logic [7:0] f1,r1,c1,n1,u1, output logic [15:0] f2,r2,c2,n2,u2
);
  ch3_94 #(.W(8))  u_a (.a_i(a8), .f_o(f1),.r_o(r1),.c_o(c1),.n_o(n1),.u_o(u1));
  ch3_94 #(.W(16)) u_b (.a_i(a16),.f_o(f2),.r_o(r2),.c_o(c2),.n_o(n2),.u_o(u2));
endmodule
