// § rootTdLeftoverStamp302
// r02: a $unit builder initialising a header parameter (v15's shape)
typedef struct packed { int unsigned aa; int unsigned bb; } loc_t;
function automatic loc_t mkloc();
  loc_t c; c.aa = 11; c.bb = 22; return c;
endfunction
module dut #(parameter loc_t LC = mkloc()) (output logic o);
  localparam int LA = LC.aa;
  assign o = LA[0];
endmodule
