// § hpSelRoute157
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  function automatic logic [3:0] f(input s_t s, input logic [15:0] m);
    logic [3:0] r;
    r = m[s.a +: 4];
    r[s.b[1:0]] = m[s.a];
    return s.a[s.b[1:0]] ? r : s.b;
  endfunction
endpackage
module top (input pk::s_t s, input logic [15:0] m, output logic [3:0] o);
  assign o = pk::f(s, m);
endmodule
