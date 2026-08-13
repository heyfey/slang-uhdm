// r10svs11 arm c1 — CHILD KIND x FORMAL FORM x CONNECTION STYLE.
//
// The SVSwitch head is a VECTOR-SIZE mismatch on work@top's Nets(): golden 1,
// ours 4.  The 3 extras are the CONNECTION-SITE nets our emitter mints for the
// interface actuals of `testcase TC (mem_intf,input_intf,output_intf);` — a
// PROGRAM instance.  This arm crosses the three axes that pairing confounds:
//
//   (a) child kind      : module   vs   program
//   (b) formal port form: `ifa.MP p`  vs  `ifa p`
//   (c) connection style: positional vs named
//
// Every interface instance is connected to EXACTLY ONE child, so the
// "connected to MULTIPLE children" rule (a separate clause in the producer)
// cannot confound any cell.  Cell value = does work@top list a logic_net of
// that instance's name.
interface ifa(input bit clk);
  logic sig;
  modport MP(input clk, output sig);
endinterface

module  m_mp (ifa.MP p);
  logic q;
endmodule

module  m_pl (ifa p);
  logic q;
endmodule

program p_mp (ifa.MP p);
  initial begin
    $display("p_mp");
  end
endprogram

program p_pl (ifa p);
  initial begin
    $display("p_pl");
  end
endprogram

module top();

bit Clock;

ifa a1(Clock);
ifa a2(Clock);
ifa a3(Clock);
ifa a4(Clock);
ifa a5(Clock);
ifa a6(Clock);
ifa a7(Clock);
ifa a8(Clock);

// (a) module child
m_mp u1 (a1);          // c1: module  + modport formal + positional
m_pl u2 (a2);          // c2: module  + plain   formal + positional
m_mp u5 (.p(a5));      // c5: module  + modport formal + named
m_pl u6 (.p(a6));      // c6: module  + plain   formal + named

// (a) program child
p_mp u3 (a3);          // c3: program + modport formal + positional
p_pl u4 (a4);          // c4: program + plain   formal + positional
p_mp u7 (.p(a7));      // c7: program + modport formal + named
p_pl u8 (.p(a8));      // c8: program + plain   formal + named

endmodule
