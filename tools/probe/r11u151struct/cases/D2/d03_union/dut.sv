// D2: a packed union typedef cast next to a struct evalFunc parameter.
package p;
  typedef union packed { logic [7:0] A; logic [7:0] B; } u_t;
  typedef struct packed { logic [7:0] A; logic B; } cfg_t;
  localparam u_t U = u_t'(3);
  function automatic cfg_t mk();
    cfg_t c;
    c.A = 8;
    c.B = 1'b1;
    return c;
  endfunction
  localparam cfg_t D = mk();
endpackage
module top #(parameter p::cfg_t C = p::D) (output logic o);
  assign o = C.B ^ p::U.A[0];
endmodule
