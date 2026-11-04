// § tfArgQualOutsideWriter176
package q;
  typedef struct packed { logic [3:0] a; } s_t;
endpackage
module top (input q::s_t [1:0] si, output logic [3:0] o);
  function automatic logic [3:0] f(q::s_t [1:0] x);
    return x[1].a;
  endfunction
  assign o = f(si);
endmodule
