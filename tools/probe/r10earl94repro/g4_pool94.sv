// r10earl94 arm g4 -- WHICH POOL a cast operand binds against: the gen scope's
// PARENT scope only.  Rows: 3-level nesting, shadowing, a TOP-module gen scope,
// a multi-iteration gen-for, and non-bare cast operands.  MEASUREMENT ONLY.
module ch4_94 #(parameter int unsigned W = 8) (
  input  logic [W-1:0] a_i,
  output logic [W-1:0] d1_o, d2_o, d3_o, d4_o, d5_o
);
  logic [W-1:0] m_var;
  logic [W-1:0] sh_var;
  logic [W-1:0] arr [0:1];
  assign m_var = a_i;
  assign arr[0] = a_i;

  // three levels of nesting
  if (W > 2) begin : gl1
    logic [W-1:0] v1;
    assign v1 = a_i;
    if (W > 3) begin : gl2
      logic [W-1:0] v2;
      assign v2 = a_i;
      if (W > 4) begin : gl3
        logic [W-1:0] v3;
        assign v3 = a_i;
        // v2 = parent scope, v1 = grandparent, m_var = module, v3 = own
        assign d1_o = W'(v2) ^ W'(v1) ^ W'(m_var) ^ W'(v3);
      end
    end
  end
  // SHADOWING: a gen-local with the same name as a module-level signal
  if (W > 2) begin : gsh
    logic [W-1:0] sh_var;
    assign sh_var = a_i;
    assign d2_o = W'(sh_var);
  end
  // non-bare cast operands
  if (W > 2) begin : gnb
    assign d3_o = W'(m_var[0]) ^ W'(arr[0]) ^ W'(a_i + m_var);
  end
  // multi-iteration gen-for
  for (genvar gj = 0; gj < 3; gj++) begin : gfor
    logic [W-1:0] w1;
    assign w1 = a_i;
    assign d4_o = W'(m_var) ^ W'(w1);
  end
  // a PROCESS inside a NESTED gen scope
  if (W > 2) begin : gp1
    logic [W-1:0] p1;
    assign p1 = a_i;
    if (W > 3) begin : gp2
      logic [W-1:0] p2;
      always_comb p2 = W'(p1) ^ W'(m_var);
      assign d5_o = p2;
    end
  end
endmodule

module g4_pool94_top (
  input logic [7:0] a8, input logic [15:0] a16,
  output logic [7:0] t1,t2,t3,t4,t5, output logic [15:0] s1,s2,s3,s4,s5,
  output logic [7:0] tg
);
  logic [7:0] top_var;
  assign top_var = a8;
  // a gen scope in the TOP module itself
  if (1) begin : gtop
    logic [7:0] tv;
    assign tv = a8;
    assign tg = 8'(top_var) ^ 8'(tv);
  end
  ch4_94 #(.W(8))  u_a (.a_i(a8), .d1_o(t1),.d2_o(t2),.d3_o(t3),.d4_o(t4),.d5_o(t5));
  ch4_94 #(.W(16)) u_b (.a_i(a16),.d1_o(s1),.d2_o(s2),.d3_o(s3),.d4_o(s4),.d5_o(s5));
endmodule
