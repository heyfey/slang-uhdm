// § rootTdLeftoverStamp302
// r09: the members in constant slots
typedef struct packed { int unsigned a; int unsigned b; } rc_t;
module dut(input logic [15:0] i, output logic [7:0] o);
  function automatic rc_t mk();
    rc_t c; c.a = 8; c.b = 2; return c;
  endfunction
  localparam rc_t L = mk();
  logic [L.a-1:0] w;
  assign w = i[L.a-1:0];
  assign o = {L.b{w[3:0]}};
endmodule
