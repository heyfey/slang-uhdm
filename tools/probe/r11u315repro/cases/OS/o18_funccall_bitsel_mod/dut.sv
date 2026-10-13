// § ifaceHcOpSelByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0] ck, output logic o);
  function automatic logic f(input logic x);
    return x;
  endfunction
  ifc u (.clk(f(ck[1])));
  assign o = u.sig[0];
endmodule
