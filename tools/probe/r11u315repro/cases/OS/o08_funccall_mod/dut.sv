// § ifaceHcOpSelByInst315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic a, output logic o);
  function automatic logic f(input logic x);
    return x;
  endfunction
  ifc u (.clk(f(a)));
  assign o = u.sig[0];
endmodule
