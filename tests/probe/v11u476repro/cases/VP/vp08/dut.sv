// § cloneViaProviderTopClone476
package u;
  task automatic tk(output int o, input int i);
    int w;
    w = i;
    fork
      begin int z; z = w; o = z; end
    join
  endtask
endpackage
package a;
  import u::*;
  class AC;
    task g(); int r; tk(r, 1); endtask
  endclass
endpackage
package t;
  import a::*;
  class TC; AC h; endclass
endpackage
module top; import t::*; TC o; endmodule
