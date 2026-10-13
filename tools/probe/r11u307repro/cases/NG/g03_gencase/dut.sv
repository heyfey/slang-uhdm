// § defGenUdpFormNoStmt307
module inner (input logic i, output logic o); assign o = ~i; endmodule
module outer #(parameter int M = 1) (input logic a, output logic y);
  case (M)
    1: begin : c1 inner u_in (y, a); end
    default: begin : cd assign y = a; end
  endcase
endmodule
module dut (input logic a, output logic y);
  outer u1 (.a(a), .y(y));
endmodule
