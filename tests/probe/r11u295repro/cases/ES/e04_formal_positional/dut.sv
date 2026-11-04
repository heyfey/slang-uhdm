// § escNameSpanSites295
module child (input logic \a.p , output logic \o!q ); assign \o!q  = \a.p ; endmodule
module dut (input logic a, output logic o);
  child \u.pos (a, o);
endmodule
