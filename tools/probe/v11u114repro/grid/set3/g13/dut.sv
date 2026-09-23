// face-1: concat member passed as a function argument
package q2;
  typedef struct packed { logic [3:0] pad; logic [11:0] v; logic [1:0] cfg; } s_t;
  localparam s_t IMPL = '{ pad: 4'h9, v: {6'h15, 6'h2A}, cfg: 2'b11 };
  function automatic logic [11:0] g(s_t a); return a.v; endfunction
endpackage
module top(output logic [11:0] o); assign o = q2::g(q2::IMPL); endmodule
