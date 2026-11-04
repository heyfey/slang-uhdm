// § nestChainSelects193v
module sub ();
  module inner (input logic [3:0] i, output logic [3:0] q);
    for (genvar k = 0; k < 4; k++) begin : g
      logic b;
      assign b = i[k];
      assign q[k] = b;
    end
  endmodule
endmodule
module dut (output logic [3:0] o);
  sub u_s ();
  assign o = 4'd0;
endmodule
