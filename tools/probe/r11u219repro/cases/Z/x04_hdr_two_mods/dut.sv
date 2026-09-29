// § enumTdLastWriter214 — the package in a header included by the file, two modules importing it (CRLF)
`include "p.svh"
module mm(output int o);
  import p::*;
  ALIAS_T s = M1;
  assign o = int'(s);
endmodule
module aa(output int o);
  import p::*;
  mm u(.o(o));
endmodule
