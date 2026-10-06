// § patLitFormFileAtRef256 (the pattern written in an included header inside the module)
module top(output logic [19:0] o);
  `include "pat.svh"
  assign o = H;
endmodule
