// § elabCloneInstTreeUnstored144 (--elabuhdm)
module leaf(input logic a, output logic y);
  assign y = ~a;
endmodule
module dut(input logic [1:0] a, output logic [1:0] y);
  leaf u[1:0] (.a(a), .y(y));
endmodule
