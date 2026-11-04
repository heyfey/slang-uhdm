// § defGenUdpFormNoStmt307
module leaf (output logic o, input logic i); assign o = ~i; endmodule
module outer (input logic [1:0] a, output logic [1:0] y);
  for (genvar k = 0; k < 2; k++) begin : g
    leaf u_l (y[k], a[k]);
  end
endmodule
module dut (input logic [1:0] a, output logic [1:0] y);
  outer u1 (.a(a), .y(y));
endmodule
