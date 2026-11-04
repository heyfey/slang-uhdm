// § ifaceConnCastTsNamedByPort315
package pk;
  typedef logic bit1_t;
endpackage
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] a, output logic o);
  ifc u (.clk(pk::bit1_t'(a)));
  assign o = u.sig[0];
endmodule
