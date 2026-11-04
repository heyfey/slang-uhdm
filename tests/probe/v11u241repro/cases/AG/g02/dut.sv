// § cloneAggTsAtHomeListing241
package p;
  typedef enum logic [1:0] { A, B, C } e_t;
  typedef union packed { logic [7:0] w; logic [1:0][3:0] n; } u_t;
  function automatic e_t f1(u_t x);
    e_t r;
    begin
      e_t tmp;
      tmp = e_t'(x.w[1:0]);
      r = tmp;
    end
    return r;
  endfunction
  function automatic u_t f2(e_t e);
    u_t r;
    r.w = {6'b0, e};
    return r;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top(input logic [7:0] i, output logic [1:0] o);
  import p::*;
  assign o = f1(f2(e_t'(i[1:0])));
endmodule
