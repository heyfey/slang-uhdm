// § hpLvSelIdxNamesByPath224 (a module task: the path's index a task argument)
module top(input int i);
  typedef struct { logic [3:0] arr [4]; } s_t;
  s_t s;
  task automatic t(input int j); s.arr[j][1:0] = 2'b01; endtask
  initial t(i);
endmodule
