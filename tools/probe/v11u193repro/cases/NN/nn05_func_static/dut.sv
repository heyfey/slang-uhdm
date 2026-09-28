// § nestedDefChainName193
module sub ();
  module inner (input logic [3:0] i, output logic [3:0] q);
    function automatic logic [3:0] f(logic [3:0] a);
      logic [3:0] t;
      t = a + 4'd1;
      return t;
    endfunction
    always_comb begin : blk
      logic [3:0] v;
      v = f(i);
      q = v;
    end
  endmodule
endmodule
module dut (output logic [3:0] o);
  sub u_s ();
  assign o = 4'd0;
endmodule
