// § fixArrLocalNamedAggElemTs480 (interface function, interface instantiated twice)
interface ifc;
  typedef struct packed { logic [3:0] k; logic [3:0] d; } op_t;
  function automatic logic [7:0] f(input logic [3:0] n);
    op_t acc[2];
    acc[1].k = n;
    acc[1].d = n;
    return acc[1];
  endfunction
endinterface
module top;
  ifc u();
  ifc v();
  logic [7:0] x, y;
  assign x = u.f(4'h1);
  assign y = v.f(4'h2);
endmodule
