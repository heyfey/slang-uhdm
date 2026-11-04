// § tfSigningSpanFollowsCompilePath200
package p;
  class c;
    extern function int unsigned get(int unsigned a, logic signed b);
    extern virtual task run(input bit signed x);
  endclass
  function int unsigned c::get(int unsigned a, logic signed b);
    return a;
  endfunction
  task c::run(input bit signed x);
  endtask
  import "DPI-C" function int unsigned dpi_f(input int unsigned a, input bit signed b);
endpackage
module s02; endmodule
