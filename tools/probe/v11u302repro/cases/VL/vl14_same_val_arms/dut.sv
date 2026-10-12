// § leftoverSlotSoleWriter302v
// vl14: both arms of the if write the same value from two literals; an early return beside
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } c_t;
endpackage
module dut(output logic o);
  function automatic pk::c_t mk(input bit s);
    pk::c_t c; c.a = 3;
    if (s) c.b = 5; else c.b = 5;
    return c;
  endfunction
  function automatic pk::c_t mk2(input bit s);
    pk::c_t c; c.a = 1; c.b = 7;
    if (s) return c;
    c.b = 8;
    return c;
  endfunction
  localparam pk::c_t L = mk(1'b1);
  localparam pk::c_t M = mk2(1'b1);
  localparam int unsigned LB = L.b + M.b;
  assign o = 1'b0;
endmodule
