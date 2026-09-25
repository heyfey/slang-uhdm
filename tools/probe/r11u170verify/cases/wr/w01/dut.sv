// § withRecvOnlyLastScoped157
class inner; int q[$]; endclass
class mid; inner in1; function new(); in1 = new; endfunction endclass
class outer;
  mid m; int r[$];
  function new(); m = new; endfunction
  function void f(); r = m.in1.q.find_index with (item == 3); endfunction
endclass
module top; outer o; initial begin o = new; o.f(); end endmodule
