// § modConnIpsBaseByPort317
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] v, input logic [1:0] s, output logic o);
  ifc u (.clk(v[s +: 1]));
  assign o = u.sig[0];
endmodule
