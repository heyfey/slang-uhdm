// r10uvm201 grid arm E — EXPLICIT item imports, one of them never referenced.
package p201e;
  parameter E_BASE   = 13;
  parameter E_REFU   = E_BASE;
  parameter E_UNUSED = E_BASE + 2;
endpackage
import p201e::E_REFU;
import p201e::E_UNUSED;
module m201e;
endmodule
