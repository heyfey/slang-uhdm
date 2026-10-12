// § rootTdLeftoverStamp302
// vr06: a module parameter of the $root type built by a builder with an argument, two instances overriding the argument
typedef struct packed { int unsigned a; int unsigned b; } rc_t;
function automatic rc_t mk(input int unsigned w);
  rc_t c; c.a = w; c.b = 32; return c;
endfunction
module kid #(parameter int unsigned W = 1) (output logic o);
  localparam rc_t L = mk(W);
  assign o = L.a[0];
endmodule
module dut(output logic o1, o2);
  kid #(.W(3)) u1 (.o(o1));
  kid #(.W(4)) u2 (.o(o2));
endmodule
