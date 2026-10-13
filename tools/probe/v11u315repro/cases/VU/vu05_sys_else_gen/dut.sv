// § genIfaceHcCallArgUnbound315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top #(parameter bit E = 0) (input logic a, output logic o);
  if (E) begin : g
  end else begin : h
    ifc u (.clk($unsigned(a)));
  end
  assign o = h.u.sig[0];
endmodule
