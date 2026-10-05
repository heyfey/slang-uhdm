// § impCondFlipTakenLeaf242
// The ternary parameter beside implicit nets, an interface body, a class specialization in a bound, a this. path, named and positional calls, extern and pure virtual prototypes above and below the caller.
package fp;
  parameter int WM = 2;
  parameter int LB = 3;
  parameter int W = WM == 1 ? 1 : LB;
  virtual class vb;
    pure virtual function int g(int a);
  endclass
  class c #(int N = 1);
    int v;
    extern function int f(int a = 1);
    function int h(); return this.v + N; endfunction
  endclass
  function int c::f(int a = 1); return a + N; endfunction
endpackage
interface bus_if import fp::*; #(parameter int Z = 0) ();
  logic [W-1:0] d;
endinterface
module top import fp::*; #(parameter int P = 1) (input logic [7:0] a, output logic [W-1:0] o, output logic q);
  bus_if b ();
  function automatic int ff(int x, int y = 2); return x + y; endfunction
  localparam int K = ff(.x(W));
  localparam int K2 = ff(W, 1);
  assign imp = a[0];
  assign q = imp;
  assign b.d = a[W-1:0];
  assign o = b.d;
  initial begin
    c #(W) ci;
    ci = new;
    $display("%0d %0d %0d %0d", ci.f(), ci.h(), K, K2);
  end
endmodule
