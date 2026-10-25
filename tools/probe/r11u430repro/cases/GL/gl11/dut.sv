// § defGenLpNoBlockListed430
module rr #(parameter n_p=0, m_p=2) (input [3:0] i, output [3:0] o);
  for (genvar j = 0; j < n_p; j++) begin : rof
     localparam a_lp = j + 1;
     for (genvar k = 0; k < m_p; k++) begin : inner
        localparam b_lp = k + a_lp;
     end
  end
  assign o = i;
endmodule
module top (input [3:0] i, output [3:0] o);
  rr u(.i(i), .o(o));
endmodule
