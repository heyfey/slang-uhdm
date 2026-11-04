// § defGenUdpFormNoStmt307
module inner (output logic o, input logic i, j); assign o = i & j; endmodule
module outer (input logic a, b, output logic y);
  if (1) begin : g
    inner u_in (y, a, b);
  end
endmodule
module dut (input logic a, b, output logic y);
  outer u1 (.a(a), .b(b), .y(y));
endmodule
