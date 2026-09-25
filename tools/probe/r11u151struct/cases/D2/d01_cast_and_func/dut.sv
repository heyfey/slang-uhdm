// D2: a package cast'(0) localparam next to an evalFunc-built one: the member
// stamps sit on the elaborated typedef, the definition listing's cast target
// is the definition typedef.
package p;
  typedef struct packed { logic [7:0] A; logic B; } cfg_t;
  localparam cfg_t E = cfg_t'(0);
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
