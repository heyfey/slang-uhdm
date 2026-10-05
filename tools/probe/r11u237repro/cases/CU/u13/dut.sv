// § unionRetVarAtTypeToken237
// a module function returning a module-local union typedef
module top(input logic [31:0] i, output logic [31:0] o);
  typedef union packed { logic [31:0] w; logic [3:0][7:0] b; } u_t;
  function automatic u_t f(logic [31:0] a);
    u_t r;
    r.w = a;
    return r;
  endfunction
  assign o = f(i);
endmodule
