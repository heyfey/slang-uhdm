// § stdRandomizeIsScopeRef403
module top;
  int x;
  wire std;
  task t; int s; s = std::randomize(x) with { x < 9; }; endtask
  initial t;
endmodule
