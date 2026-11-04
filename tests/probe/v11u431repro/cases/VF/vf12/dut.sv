// § caFnArgConcatFormalTs431 (an interface's continuous assignment)
interface ifc(input logic [5:0] a);
  logic [3:0] y;
  function automatic logic [3:0] f(input logic [5:0] b);
    return b[3:0];
  endfunction
  assign y = f({a[2:0], a[5:3]});
endinterface
module top(input [5:0] a, output [3:0] y);
ifc i(.a(a));
assign y = i.y;
endmodule
