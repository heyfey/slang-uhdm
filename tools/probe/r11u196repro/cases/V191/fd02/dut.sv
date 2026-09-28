// § formalDefaultNamedThroughFormal191: a class method default reading a class property and a static function call, a task default with a ternary
package p;
  class c;
    int lim = 4;
    static function int dflt(); return 2; endfunction
    function int m(int x, int y = x > lim ? dflt() : lim);
      return x + y;
    endfunction
    task t(int z, int w = (z == 0) ? 1 : z);
    endtask
  endclass
endpackage
module top; endmodule
