// § rootTdLeftoverStamp302
// r03: a $unit builder initialising a module localparam
typedef struct packed { int unsigned aa; int unsigned bb; } loc_t;
function automatic loc_t mkloc();
  loc_t c; c.aa = 5; c.bb = 6; return c;
endfunction
module dut (output logic o);
  localparam loc_t L = mkloc();
  localparam int LB = L.bb;
  assign o = LB[0];
endmodule
