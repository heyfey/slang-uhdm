// § tfArgTypedefLastWriter146
package p;
  typedef enum logic {A, B} e_t;
  function automatic logic g(e_t x [2], ref e_t y, input e_t z = A);
    return x[0] == y;
  endfunction
endpackage
module top(output logic o);
endmodule
