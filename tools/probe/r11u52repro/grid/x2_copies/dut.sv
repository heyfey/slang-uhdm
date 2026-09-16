// r11u52 ROAD C — COPY POSITIONS and the OVERRIDE question.  The same
// unpacked-dim typedef in a module instantiated TWICE, once with an
// overriding NDATA.  Asks: does golden keep the element bound symbolic in the
// OVERRIDDEN instance's copy too, and what name prefix does each copy carry?
module sub #(parameter int unsigned NDATA = 2, parameter int unsigned DEPTH = 4)
           (output logic [NDATA-1:0] o);
  typedef logic [NDATA-1:0] up_t [DEPTH];
  up_t u;                       // net-declaration holder
  logic [NDATA-1:0] w;          // plain net (control)
  function automatic logic [NDATA-1:0] f();
    up_t lv;                    // function-LOCAL of the typedef type
    return lv[0];
  endfunction
  assign o = u[0] | w | f();
endmodule
module dut (output logic [3:0] o);
  logic [1:0] a; logic [3:0] b;
  sub #(.NDATA(2)) i0 (.o(a));
  sub #(.NDATA(4)) i1 (.o(b));
  assign o = b | {2'b0, a};
endmodule
