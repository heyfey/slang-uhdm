// The v2_kind94 :40 shape verbatim, reduced: a user call + two $signed forms.
module ch #(parameter int unsigned W = 8)(input logic [W-1:0] b_i, output logic [W-1:0] o);
  logic [W-1:0] m_var;
  assign m_var = b_i;
  function automatic logic [W-1:0] idf(input logic [W-1:0] x); return x; endfunction
  if (W > 2) begin : gen_k
    assign o = idf(W'(m_var)) ^ W'($signed(m_var)) ^ $signed(W'(m_var));
  end
endmodule
module top(input logic [7:0] b8, output logic [7:0] q);
  ch #(.W(8)) u_a(.b_i(b8), .o(q));
endmodule
