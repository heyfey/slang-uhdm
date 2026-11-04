// § ifaceHcVarSelWholeByInst319
package mask_pkg;
  localparam logic [1:0][1:0] PA = 4'h6;
endpackage
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic s, output logic o);
  ifc u (.clk(mask_pkg::PA[s][0]));
  assign o = u.sig[0];
endmodule
