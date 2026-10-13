// § genConnTernSysActual315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top #(parameter int P = 1) (input logic a, input logic b, input logic s, output logic o);
  case (P)
    0: begin : g0 assign o = a; end
    default: begin : gd
      child c0 (.clk(s ? b : a), .o(o));
    end
  endcase
endmodule
