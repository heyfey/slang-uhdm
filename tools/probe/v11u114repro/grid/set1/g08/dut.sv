// face-1 break: concat with a function call leaf
package q2;
  function automatic logic [5:0] f(); return 6'h3; endfunction
  typedef struct packed { logic [3:0] pad; logic [11:0] v; logic [1:0] cfg; } s_t;
  localparam s_t IMPL = '{ pad: 4'h9, v: {f(), 6'h1}, cfg: 2'b11 };
endpackage
module top(output logic [11:0] o); assign o = q2::IMPL.v; endmodule
