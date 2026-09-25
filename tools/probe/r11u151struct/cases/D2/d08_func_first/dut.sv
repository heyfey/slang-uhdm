// D2: the evalFunc parameter declared BEFORE the cast.
package p;
  typedef struct packed { logic [7:0] A; logic B; } cfg_t;
  function automatic cfg_t mk();
    cfg_t c;
    c.A = 8;
    c.B = 1'b1;
    return c;
  endfunction
  localparam cfg_t D = mk();
  localparam cfg_t E = cfg_t'(0);
endpackage
module top #(parameter p::cfg_t C = p::D) (output logic o);
  assign o = C.B;
endmodule
