// § structCopyNestedAnnotDeep232
// a nested annotated struct in two instances with different values, and the nested member passed as its own parameter
package p;
  typedef struct packed { logic [3:0] a; logic flag; } u_t;
  typedef struct packed { u_t u; logic [3:0] z; } cfg_t;
  function automatic cfg_t setc(int v);
    cfg_t c;
    c.u.a = v[3:0];
    c.u.flag = 1'b0;
    c.z = 4'd1;
    return c;
  endfunction
endpackage
module leaf import p::*; #(parameter u_t U = '0) (output logic [4:0] o);
  assign o = U;
endmodule
module child import p::*; #(parameter cfg_t C = setc(2)) (output logic [4:0] o);
  leaf #(.U(C.u)) l (.o(o));
endmodule
module top(output logic [4:0] o1, output logic [4:0] o2);
  child #(.C(p::setc(6))) c1 (.o(o1));
  child c2 (.o(o2));
endmodule
