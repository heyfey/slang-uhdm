// § inlineAggReturnVarSpan299
interface ifc (input logic [3:0] i);
  function automatic struct packed { logic a; logic b; } [1:0] f(input logic [3:0] v);
    return v;
  endfunction
  logic [3:0] o;
  assign o = f(i);
endinterface
module dut(input logic [3:0] i, output logic [3:0] o);
  ifc u (i);
  assign o = u.o;
endmodule
