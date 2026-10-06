// § lvStreamBaseKeepsActual258 (a this. path streaming target in a class method)
package p;
  class c;
    logic [7:0] f;
    function void w(logic [3:0] x);
      {>>{this.f[3:0]}} = x;
    endfunction
  endclass
endpackage
module top; endmodule
