// v226 b06 — the CONCURRENT-ASSERTION fence, all four item forms, plus the
// procedural forms that must NOT be fenced.
interface ba_if;
  logic clk, a, b;
  int   n;

  // Concurrent assertion ITEMS — golden lists them under Assertions(), the
  // def view fills that not at all; the patch must skip them, minting nothing.
  assert  property (@(posedge clk) a |-> b);
  assume  property (@(posedge clk) a |-> b);
  cover   property (@(posedge clk) a);
  restrict property (@(posedge clk) a);

  // A labelled one.
  lbl_a: assert property (@(posedge clk) b |-> a);

  // These ARE processes and must be listed.
  initial n = 0;
  always_comb n = a ? 1 : 0;
  // An IMMEDIATE assertion inside a real process (not fenced).
  always @(posedge clk) begin
    assert (a == b) n = 1; else n = 2;
  end
  // A concurrent assertion INSIDE a process (the process is still a process).
  always @(posedge clk) begin
    assert property (a |-> b);
  end
endinterface
