// § sysCallInIdxNamedBySel319
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
module top (input logic [1:0][1:0] m, input logic [3:0] ck, input logic [1:0] s, input logic [1:0] t, input logic [1:0] k [2], input logic a, output logic o);
  function automatic logic [1:0] f(input logic [1:0] x); return x; endfunction
  ifc u (.clk(ck[$unsigned(f(s))] | a));
  assign o = u.sig[0];
endmodule
