// § packedArrTdElemRefName137
module top(output logic o);
  typedef enum logic {X, Y} e_t;
  typedef e_t [1:0] ea_t;
  function automatic logic f(input ea_t a);
    return a[0];
  endfunction
  ea_t v;
  assign o = f(v);
endmodule
