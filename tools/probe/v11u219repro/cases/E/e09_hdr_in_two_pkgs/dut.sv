// § enumTdLastWriter214 — one header defining an enum included in two packages; a third package imports one of them; a module imports the other
package pa;
  `include "td.svh"
endpackage
package pb;
  `include "td.svh"
endpackage
package qc;
  import pa::*;
  function automatic h_t f(h_t v); return v; endfunction
endpackage
module top(output int o);
  import pb::*;
  h_t v;
  assign v = H2;
  assign o = int'(v) + int'(qc::f(pa::H1));
endmodule
