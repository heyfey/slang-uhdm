// § genConnTernSysActual315
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top #(parameter int K = 0) (input logic a, input logic b, input logic s, output logic o);
  case (K)
    0: begin : g0
      assign o = a;
    end
    default: begin : gd
      child c0 (.clk(s ? a : b), .o(o));
    end
  endcase
endmodule
