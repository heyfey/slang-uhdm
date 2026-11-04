// § instBodyMemberWinsFlatLocal238v
// a paren-less module task (io in the body) whose local shadows a module variable, and one that does not
module top;
  int vals[4];
  task automatic t;
    input int a;
    int vals[$];
    int other[$];
    foreach (vals[i]) vals[i] = a;
    foreach (other[i]) other[i] = a;
  endtask
  initial t(1);
endmodule
