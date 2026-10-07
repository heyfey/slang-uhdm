// § tpPackedArrCaUnparent275 — control: a named struct element
package p;
  typedef struct packed { logic a; logic b; } s_t;
endpackage
module dut #(parameter type T = p::s_t [1:0]) (input T i, output T o);
  assign o = i;
endmodule
