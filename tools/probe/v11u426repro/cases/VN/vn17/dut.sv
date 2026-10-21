// § namedTypeLocalTfItemOutsideClass426
typedef struct packed { logic [3:0] a; } box_t;
module child(input logic [3:0] i, output logic [3:0] o);
  function logic [3:0] f;
    input logic [3:0] x;
    box_t r;
    r.a = x + 1;
    f = r.a;
  endfunction
  assign o = f(i);
endmodule
module top(input logic [3:0] i, output logic [3:0] o1, o2);
  child c1(.i(i), .o(o1));
  child c2(.i(~i), .o(o2));
endmodule
