// § caDelayFirstOnly164 — a net declaration with a delay and two declarators (control)
module top (input a, input e);
  wire #2 x = a, y = e;
endmodule
