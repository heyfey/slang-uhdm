// D2: def_ctx_struct_param's module shape: the module default reads the cast
// parameter, the instance overrides with the evalFunc one.
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
module leaf #(parameter p::cfg_t C = p::E) (output logic o);
  assign o = C.B;
endmodule
module top(output logic o);
  leaf #(.C(p::D)) u(.o(o));
endmodule
