// D2: two casts to the stamped typedef.
package p;
  typedef struct packed { logic [7:0] A; logic B; } cfg_t;
  localparam cfg_t E0 = cfg_t'(0);
  localparam cfg_t E1 = cfg_t'(1);
  function automatic cfg_t mk();
    cfg_t c;
    c.A = 8;
    c.B = 1'b1;
    return c;
  endfunction
  localparam cfg_t D = mk();
endpackage
module top #(parameter p::cfg_t C = p::D) (output logic o);
  assign o = C.B;
endmodule
