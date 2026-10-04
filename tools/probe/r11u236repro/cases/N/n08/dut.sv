// § namedCallArgFormalTs236 — a named call to a package function, qualified and imported, with vector formals
package p;
  function automatic logic [7:0] f(logic [7:0] x, logic [3:0] y);
    return x + y;
  endfunction
endpackage
module top(input logic [7:0] a, input logic [3:0] b, output logic [7:0] o, output logic [7:0] o2);
  import p::*;
  assign o = p::f(.y(b), .x(a));
  assign o2 = f(.y(b), .x(a));
endmodule
