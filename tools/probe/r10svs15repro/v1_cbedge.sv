// r10svs15 VERIFIER arm v1 — shapes § cbEventRefFirstInstance15 was NOT measured
// on.  Each cell asks whether the law OVER-fires or UNDER-fires somewhere the
// implementer's a1/a2/a3 could not reach.
//
//   f1  instances minted inside a GENERATE FOR loop (gen-scope elab views)
//   f2  one instance at top + one inside a GENERATE IF (mixed scope kinds)
//   f3  an interface def that is NEVER instantiated (def view, no elab view)
//   f4  an interface instantiated INSIDE ANOTHER INTERFACE (nested carrier)
//   f5  a clocking event whose signal is a MODPORT-visible net, array[3]
//   f6  two clocking blocks whose events name THE SAME signal (key collision on
//       (csyn,name)?  no: two csyn, one name)
`timescale 1ns/1ns

interface f1_if(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    output d;
  endclocking
endinterface

interface f2_if(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    output d;
  endclocking
endinterface

// f3 — DEF VIEW ONLY: never instantiated anywhere.
interface f3_if(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    output d;
  endclocking
endinterface

interface f4_inner(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    output d;
  endclocking
endinterface

interface f4_outer(input bit clock);
  f4_inner in0(clock);
  f4_inner in1(clock);
endinterface

interface f5_if(input bit clock);
  logic d;
  clocking cb@(posedge clock);
    output d;
  endclocking
  modport MP(clocking cb, input clock);
endinterface

interface f6_if(input bit clock);
  logic d, e;
  clocking cba@(posedge clock);
    output d;
  endclocking
  clocking cbb@(posedge clock);
    output e;
  endclocking
endinterface

module top();
  bit Clock;
  genvar gi;
  generate
    for (gi = 0; gi < 3; gi = gi + 1) begin : gblk
      f1_if f1u(Clock);
    end
  endgenerate
  f2_if f2top(Clock);
  generate
    if (1) begin : gif
      f2_if f2gen(Clock);
    end
  endgenerate
  f4_outer f4o[2](Clock);
  f5_if f5a[3](Clock);
  f6_if f6a[2](Clock);
endmodule
