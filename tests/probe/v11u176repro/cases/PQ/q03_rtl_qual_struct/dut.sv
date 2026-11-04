// § tfArgQualOutsideWriter176
package q;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
endpackage
module top (input q::s_t si, output logic [3:0] o);
  function automatic logic [3:0] add(q::s_t x);
    return x.a + x.b;
  endfunction
  assign o = add(si);
endmodule
