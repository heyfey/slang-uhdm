// § defGenUdpFormNoStmt307
module inner (input logic i, output logic o); assign o = ~i; endmodule
module outer (input logic a, b, output logic y, z);
  if (1) begin : g
    inner u_in (a, y), u_jn (b, z);
  end
endmodule
module dut (input logic a, b, output logic y, z);
  outer u1 (.a(a), .b(b), .y(y), .z(z));
endmodule
