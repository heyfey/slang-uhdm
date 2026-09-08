// v5 — ESCAPED IDENTIFIERS in the imported package and in the interface.
package pv5;
  int \esc$var5 = 1;
  logic [3:0] \a.b.c5 = 4'h2;
endpackage

interface \if$v5 ;
  import pv5::*;
  logic \own$v5 ;
endinterface
