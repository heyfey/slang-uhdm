// § genConnTernSysActual315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
interface host (input logic [1:0] v, input logic s);
  for (genvar i = 0; i < 2; i++) begin : g
    ifc u (.clk(s ? v[i] : v[1-i]));
  end
endinterface
module top (input logic [1:0] v, input logic s, output logic o);
  host h (.v(v), .s(s));
  assign o = h.g[0].u.sig[0];
endmodule
