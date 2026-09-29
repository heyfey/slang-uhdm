// § modStructMemberQualSpan214 — a struct typedef with a qualified member bound declared in a function body and as a port type of a submodule
package cfg;
  localparam int W = 5;
endpackage
module m(input logic [cfg::W-1:0] i, output logic [15:0] o);
  typedef struct packed { logic [cfg::W-1:0] a; logic [cfg::W:1] b; } s_t;
  function automatic logic [15:0] f(input logic [cfg::W-1:0] v);
    s_t t;
    t.a = v; t.b = v;
    return 16'(t);
  endfunction
  assign o = f(i);
endmodule
module top(input logic [4:0] i, output logic [15:0] o);
  m u(.i(i), .o(o));
endmodule
