// § ifaceHcOpSelByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [3:0] ck, output logic [3:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar j = 0; j < 2; j++) begin : h
      ifc u (.clk(ck[i] & ck[j+2]));
      assign o[i*2+j] = u.sig[0];
    end
  end
endmodule
