// § impArrParamTsOwnRanges242
// The imported array beside implicit nets, an interface body, a class specialization bound by an element, a named call reading an element, a generate-for over its size.
package hp;
  parameter int A [3] = '{2, 3, 4};
  class c #(int N = 1);
    function int f(); return N; endfunction
  endclass
endpackage
interface bus_if import hp::*; #(parameter int Z = 0) ();
  logic [A[0]-1:0] d;
endinterface
module top import hp::*; #(parameter int P = 1) (input logic [7:0] a, output logic [A[1]-1:0] o, output logic q);
  bus_if b ();
  function automatic int ff(int x, int y = 2); return x + y; endfunction
  localparam int K = ff(.x(A[2]));
  assign imp = a[0];
  assign q = imp;
  assign b.d = a[A[0]-1:0];
  assign o = a[A[1]-1:0];
  for (genvar g = 0; g < 3; g++) begin : gl
    logic [A[g]-1:0] w;
    assign w = a[A[g]-1:0];
  end
  initial begin
    c #(A[0]) ci;
    ci = new;
    $display("%0d %0d", ci.f(), K);
  end
endmodule
