// § enumPkgWriterImportsType219 — a package imports the enum by name (a writer), a second package imports only a value (no writer), a module imports the home package last
package p;
  typedef enum logic [2:0] {S0, S1, S2, S3} st_t;
endpackage
package qn;
  import p::st_t;
  function automatic st_t nx(st_t s); return st_t'(s + 1); endfunction
endpackage
package qv;
  import p::S2;
  localparam int K = 2;
endpackage
module top(output logic [2:0] o);
  import p::*;
  import qn::*;
  st_t s;
  assign s = S1;
  assign o = nx(s);
endmodule
