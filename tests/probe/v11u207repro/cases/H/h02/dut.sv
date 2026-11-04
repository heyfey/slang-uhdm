// § bitSelMethodCallIdxSpan207: an interface body calling a class handle's method as an index in its own always block and function, the interface instantiated in a module (with § parenMethodCallPathSpan207's parenthesized form beside it)
class K;
  int v;
  function int gi(int a); return a + v; endfunction
endclass
interface bus_if(input logic clk);
  int arr [8];
  int o;
  K k;
  function automatic int pick(int i); return arr[k.gi(i)] + arr[(k.gi(i))]; endfunction
  always @(posedge clk) o <= arr[k.gi(1)] + (k.gi(2));
endinterface
module top(input logic clk, output int o);
  bus_if b(clk);
  assign o = b.o;
endmodule
