// § hpTrailIpsNamesByPath218 — x09_func_body: inside a function body
package tp;
  typedef struct packed { logic v; logic [31:0] a_address; logic [31:0] a_data; logic [3:0] a_mask; } req_t;
endpackage
module m #(parameter int B = 2) (input tp::req_t tl_i, output logic [7:0] o);
  function automatic logic [7:0] f(tp::req_t r);
    return r.a_address[B+:8];
  endfunction
  assign o = f(tl_i);
endmodule
module top(input tp::req_t tl_i, output logic [7:0] o);
  m u(.tl_i(tl_i), .o(o));
endmodule
