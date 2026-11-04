// § defGenUdpFormNoStmt307
module leaf (output logic o, input logic i); assign o = ~i; endmodule
module outer #(parameter bit P = 0) (input logic a, output logic y);
  if (P) begin : g1
    assign y = a;
  end else begin : g2
    leaf u_l (y, a);
  end
endmodule
module dut (input logic a, output logic y);
  outer u1 (.a(a), .y(y));
endmodule
