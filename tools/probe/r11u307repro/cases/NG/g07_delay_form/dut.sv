// § defGenUdpFormNoStmt307
module inner #(parameter bit P = 0) (input logic i, output logic o); assign o = i ^ P; endmodule
module outer (input logic a, output logic y);
  if (1) begin : g
    inner #(1) u_in (a, y);
  end
endmodule
module dut (input logic a, output logic y);
  outer u1 (.a(a), .y(y));
endmodule
