// § tfArgClassMethodOrder176
package p1;
  typedef enum logic [1:0] {IDLE, RUN, STOP} st_e;
  class outer;
    class inner;
      static function void put(st_e s, int n = 1);
      endfunction
    endclass
    extern static function void set(st_e s);
  endclass
  function void outer::set(st_e s);
  endfunction
endpackage
module top;
  import p1::*;
  initial begin outer::inner::put(RUN); outer::set(STOP); end
endmodule
