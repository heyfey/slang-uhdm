// § defGenUdpFormNoStmt307
module inner (input logic i, output logic o); assign o = ~i; endmodule
module dut (input logic a, output logic y);
  if (1) begin : g
    inner u_in (y, a);
  end
endmodule
