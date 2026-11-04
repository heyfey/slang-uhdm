// § topPkgTdDefWalkKeepsDef231 — a top-listed typedef the definition listing reaches through a struct member
package q2;
  typedef logic [1:0] ut_e;
  typedef ut_e [0:2] row_t;
  typedef struct packed { logic [3:0] pad; row_t [0:1] U; logic [1:0] cfg; } impl_t;
  localparam impl_t IMPL = '{pad: 4'h9, U: {2'b01, 2'b01, 2'b01, 2'b10, 2'b10, 2'b10}, cfg: 2'b11};
  class c;
    extern function void set(row_t v);
  endclass
  function void c::set(row_t v);
  endfunction
endpackage
module dut (output logic [17:0] o);
  assign o = q2::IMPL;
endmodule
