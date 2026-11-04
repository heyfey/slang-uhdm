// D2: a control: the cast's typedef belongs to ANOTHER package (outside the
// pass-140 predicate).
package q;
  typedef struct packed { logic [7:0] A; logic B; } cfg_t;
  function automatic cfg_t mk();
    cfg_t c;
    c.A = 8;
    c.B = 1'b1;
    return c;
  endfunction
  localparam cfg_t D = mk();
endpackage
package p;
  localparam q::cfg_t E = q::cfg_t'(0);
endpackage
module top #(parameter q::cfg_t C = q::D) (output logic o);
  assign o = C.B ^ p::E.B;
endmodule
