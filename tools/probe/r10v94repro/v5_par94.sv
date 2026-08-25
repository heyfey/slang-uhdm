// r10v94 arm v5 -- three instantiations from ONE span with DIFFERENT parameters,
// a DEFPARAM'd parameter, a gen-scope localparam, and a module var of struct /
// enum / unpacked-array type as the cast operand.  MEASUREMENT ONLY.
module chv5_94 #(parameter int unsigned W = 8) (
  input  logic [W-1:0] a_i,
  output logic [W-1:0] o1,o2,o3,o4
);
  typedef struct packed { logic [3:0] hi; logic [3:0] lo; } st_t;
  typedef enum logic [1:0] { EA=0, EB=1 } en_t;
  st_t st_var;
  en_t en_var;
  logic [W-1:0] arr_var [0:1];
  logic [W-1:0] m_var;
  assign st_var = '0;
  assign en_var = EA;
  assign m_var  = a_i;

  if (W > 2) begin : gen_p
    localparam int unsigned GLP = W + 1;
    logic [W-1:0] p_loc;
    assign p_loc = a_i;
    assign o1 = W'(m_var) ^ W'(GLP);
    assign o2 = W'(st_var);
    assign o3 = W'(en_var);
    if (W > 3) begin : gen_q
      // the PARENT gen block's localparam and local, from a nested scope
      assign o4 = W'(GLP) ^ W'(p_loc) ^ W'(m_var);
    end
  end
endmodule

module chv5b_94 #(parameter int unsigned W = 8) (
  input logic [W-1:0] a_i, output logic [W-1:0] o1);
  logic [W-1:0] n_var;
  assign n_var = a_i;
  if (W > 2) begin : gen_d
    assign o1 = W'(n_var) ^ W'(a_i);
  end
endmodule

module v5_par94_top (
  input logic [7:0] a8, input logic [15:0] a16, input logic [31:0] a32,
  output logic [7:0]  p1,p2,p3,p4,
  output logic [15:0] q1,q2,q3,q4,
  output logic [31:0] r1,r2,r3,r4,
  output logic [7:0]  d1
);
  chv5_94 #(.W(8))  u_a (.a_i(a8),  .o1(p1),.o2(p2),.o3(p3),.o4(p4));
  chv5_94 #(.W(16)) u_b (.a_i(a16), .o1(q1),.o2(q2),.o3(q3),.o4(q4));
  chv5_94 #(.W(32)) u_c (.a_i(a32), .o1(r1),.o2(r2),.o3(r3),.o4(r4));
  chv5b_94 u_d (.a_i(a8), .o1(d1));
  defparam u_d.W = 8;
endmodule
