// r10svs12 arm d1 — THE INTERFACE-ARRAY module_array's OWN BROADCAST PORT:
// connection style x port count x written order.
//
// The head is `port: , id:1164, 38:33-38:38` under `module_array
// (work@output_interface)` — the def-view broadcast port list of
// `output_interface output_intf[4](Clock);` (SVSwitch top.sv:38).  The compared
// field that fails is the port's own vpiName (ports::Compare reaches it through
// BaseClass::Compare, before every vector), golden EMPTY vs ours `clock`; one
// level down the HighConn ref_obj's vpiFullName differs too
// (`work@top.output_intf.Clock` vs `...output_intf.clock.Clock`).
//
// The witness confounds THREE axes at once — the connection is POSITIONAL, the
// container is an interface ARRAY, and the instantiated def is an INTERFACE.
// This arm holds the container fixed (always an interface array) and crosses
// connection style against port count and written order.  d2 varies the
// container/def; d3 varies the actual's form.
//
// Cells are read by portread.py off the DEF view (uhdmallModules), which is the
// only view whose module_array carries ports at all: SVSwitch's ELAB view lists
// the array only as a weakly-referenced col-0 tail object with no port vector,
// on BOTH sides (measured).
interface if1(input bit clk);
  logic sig;
  modport MP(input clk, output sig);
endinterface

interface if2(input bit clk, input bit rst);
  logic sig;
  modport MP(input clk, input rst, output sig);
endinterface

module top();

bit Clock;
bit Rst;
bit clk;                     // for the `.clk` SHORTHAND cell h7

// h1  POSITIONAL, 1 port                       <- THE WITNESS SHAPE
if1 a1[4](Clock);
// h2  NAMED, 1 port
if1 a2[4](.clk(Clock));
// h3  POSITIONAL, 2 ports  (2 ordered terminals: a UDP-shaped PARSE)
if2 a3[4](Clock, Rst);
// h4  NAMED, 2 ports, written in DECLARATION order
if2 a4[4](.clk(Clock), .rst(Rst));
// h5  NAMED, 2 ports, written in REVERSED order (the def-order re-key rule)
if2 a5[4](.rst(Rst), .clk(Clock));
// h6  NAMED but EMPTY actual  `.clk()`
if1 a6[4](.clk());
// h7  `.clk` SHORTHAND (no parens, no actual; LRM 23.3.2.3)
if1 a7[4](.clk);
// h8  SCALAR interface instance, POSITIONAL — the ref_module control that
//     already matches golden and must keep matching
if1 s1(Clock);
// h9  SCALAR interface instance, NAMED — the other ref_module control
if1 s2(.clk(Clock));
// h10 POSITIONAL, 1 port, on a SECOND array of the same def (no sharing)
if1 a8[2](Clock);

endmodule
