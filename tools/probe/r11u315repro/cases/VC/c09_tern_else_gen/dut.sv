// § genConnTernSysActual315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module child (input logic clk, output logic o);
  assign o = clk;
endmodule
module top #(parameter int P = 0) (input logic a, input logic b, input logic s, output logic o);
  if (P == 1) begin : g
    assign o = a;
  end else begin : h
    child c0 (.clk(s ? a : b), .o(o));
  end
endmodule
