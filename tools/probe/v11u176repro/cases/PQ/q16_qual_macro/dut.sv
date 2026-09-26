// § tfArgQualOutsideWriter176
`define T q::s_t
package q;
  typedef struct packed { logic [3:0] a; } s_t;
endpackage
module top (input q::s_t si, output logic [3:0] o);
  function automatic logic [3:0] f(`T x);
    return x.a;
  endfunction
  assign o = f(si);
endmodule
