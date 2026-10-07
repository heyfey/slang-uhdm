// § pkgNetNamedTsDimEnd280
// a module using the typedef in a generate block and a function
package pk;
  typedef struct packed { logic [3:0] a; } st_t;
  st_t v [0:1];
endpackage
module top(output logic [3:0] o);
  function automatic pk::st_t f(pk::st_t x); return x; endfunction
  if (1) begin : g
    pk::st_t y;
    assign y = f('0);
    assign o = y.a;
  end
endmodule
