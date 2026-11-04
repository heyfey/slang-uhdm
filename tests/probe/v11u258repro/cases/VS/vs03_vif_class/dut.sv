// § lvStreamBaseKeepsActual258 (a virtual-interface member range select as a streaming target in a class method)
interface bif; logic [7:0] read_data; logic [7:0] wr_data; logic [1:0][3:0] d; endinterface
package p;
  class c; virtual bif vif;
    function void w(logic [3:0] x); {>>{vif.read_data[3:0]}} = x; endfunction
  endclass
endpackage
module top; bif b(); endmodule
