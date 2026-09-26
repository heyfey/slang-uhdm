// § tfArgQualOutsideWriter176
package pa;
  typedef struct packed { logic [1:0] a; } s_t;
endpackage
package pz;
  typedef struct packed { logic [2:0] b; } s_t;
endpackage
module top (input pa::s_t x, input pz::s_t y, output logic [4:0] o);
  function automatic logic [4:0] f(pa::s_t u, pz::s_t v);
    return {u.a, v.b};
  endfunction
  assign o = f(x, y);
endmodule
