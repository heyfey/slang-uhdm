// v15 — a MODULE-LOCAL struct typedef and a module-local const function, plus
// a PROGRAM holder reading the same member.
typedef struct packed {
  int unsigned aa;
  int unsigned bb;
} loc_t;

function automatic loc_t mkloc();
  loc_t c;
  c.aa = 11;
  c.bb = 22;
  return c;
endfunction

module dut #(
    parameter loc_t LC = mkloc()
) (
    output logic o
);
  localparam int LA = LC.aa;
  localparam int LB = LC.bb + 1;
  assign o = ^{LA[0], LB[0]};
endmodule
