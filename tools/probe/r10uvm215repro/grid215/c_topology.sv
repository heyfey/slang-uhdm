// r10uvm215 GRID ARM C — THE BINDING RISK.  A modport object is what an
// interface PORT's HighConn/LowConn ref and a modport-qualified port view bind
// to.  If golden mints NO object for a clocking-only modport, then a port
// QUALIFIED BY THAT MODPORT has nothing to bind to on golden's side either —
// and this arm is what says so, next to the simple-port control that must keep
// binding exactly as it does today.
//
// c1 module port qualified by a CLOCKING-ONLY modport
// c2 module port qualified by a SIMPLE-PORT modport  (the control)
// c3 one interface, BOTH kinds of modport, both used as ports
// c4 TWO SIMPLE modports, port qualified by ONE — does the PORT VIEW list only
//    the connected modport, or every modport the interface declares?  (the
//    distinguisher for the existing "connected modport only" rule)
// c5 a clocking-only modport BESIDE a simple one, port qualified by the SIMPLE
// c6 THREE modports (one clocking-only, TWO simple), port qualified by the
//    CLOCKING-ONLY one — does the port view then list ALL the minted modports,
//    or none?  (the fallback the filter takes when the connected modport was
//    never minted)

interface c1_if;
  logic clk;
  logic frame;
  clocking cb @(posedge clk);
    inout frame;
  endclocking
  modport mpc (clocking cb);
endinterface

interface c2_if;
  logic clk;
  logic d;
  modport mps (input clk, output d);
endinterface

interface c3_if;
  logic clk;
  logic frame;
  logic d;
  clocking cb @(posedge clk);
    inout frame;
  endclocking
  modport mpc (clocking cb);
  modport mps (input clk, output d);
endinterface

interface c4_if;
  logic clk;
  logic d;
  modport mps1 (input clk);
  modport mps2 (output d);
endinterface

interface c5_if;
  logic clk;
  logic frame;
  logic d;
  clocking cb @(posedge clk);
    inout frame;
  endclocking
  modport mpc (clocking cb);
  modport mps (input clk, output d);
endinterface

interface c6_if;
  logic clk;
  logic d;
  logic frame;
  clocking cb @(posedge clk);
    inout frame;
  endclocking
  modport mpc (clocking cb);
  modport mpa (input clk);
  modport mpb (output d);
endinterface

module c6_sub (c6_if.mpc p);
endmodule

module c4_sub (c4_if.mps1 p);
endmodule

module c5_sub (c5_if.mps p);
  assign p.d = p.clk;
endmodule

module c1_sub (c1_if.mpc p);
endmodule

module c2_sub (c2_if.mps p);
  assign p.d = p.clk;
endmodule

module c3_sub (c3_if.mpc a, c3_if.mps b);
  assign b.d = b.clk;
endmodule

module top;
  c1_if i1();
  c2_if i2();
  c3_if i3();
  c1_sub s1(i1);
  c2_sub s2(i2);
  c3_sub s3(i3, i3);
  c4_if i4();
  c5_if i5();
  c4_sub s4(i4);
  c5_sub s5(i5);
  c6_if i6();
  c6_sub s6(i6);
endmodule
