// r10v94 arm v2 -- the CAST-FORM grid: size cast, keyword casts (int/signed/
// unsigned/byte), a typedef'd type cast, a package type cast, a parameter-sized
// cast, and a cast under a sys_func_call / function-call argument.
// MEASUREMENT ONLY.
package pkv2_94;
  typedef logic [7:0] pk_t;
  localparam int unsigned PW = 8;
endpackage

module chv2_94 #(parameter int unsigned W = 8) (
  input  logic signed [W-1:0] a_i,
  input  logic [W-1:0] b_i,
  output logic [W-1:0] o1,o2,o3,o4,o5,o6,o7,o8
);
  import pkv2_94::*;
  typedef logic [W-1:0] loc_t;
  logic [W-1:0] m_var;
  logic signed [W-1:0] s_var;
  assign m_var = b_i;
  assign s_var = a_i;

  function automatic logic [W-1:0] idf (input logic [W-1:0] x);
    return x;
  endfunction

  if (W > 2) begin : gen_k
    logic [W-1:0] g_loc;
    assign g_loc = b_i;
    // size cast (control)
    assign o1 = W'(m_var);
    // keyword casts
    assign o2 = int'(m_var);
    assign o3 = signed'(s_var);
    assign o4 = unsigned'(s_var);
    assign o5 = byte'(m_var);
    // typedef'd type casts
    assign o6 = loc_t'(m_var);
    assign o7 = pk_t'(m_var);
    // cast under a function-call arg and a sys_func_call arg
    assign o8 = idf(W'(m_var)) ^ W'($signed(m_var)) ^ $signed(W'(m_var));
  end
endmodule

module v2_kind94_top (
  input logic signed [7:0] a8, input logic [7:0] b8,
  output logic [7:0] q1,q2,q3,q4,q5,q6,q7,q8
);
  chv2_94 #(.W(8)) u_a (.a_i(a8), .b_i(b8), .o1(q1),.o2(q2),.o3(q3),.o4(q4),.o5(q5),.o6(q6),.o7(q7),.o8(q8));
endmodule
