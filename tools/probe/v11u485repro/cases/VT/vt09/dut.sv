// § ndtSameFileDirective485v
`default_nettype tri
interface ifc (input logic clk); logic a; endinterface
`include "t.svh"
`default_nettype wire
