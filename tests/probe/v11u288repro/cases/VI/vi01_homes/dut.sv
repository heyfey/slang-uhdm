// § incDecIpsWholeSpan288 — indexed part-select increments in a class method, a package function and an interface process, beside a plain part-select control
package ip;
  function automatic logic [7:0] pf(logic [7:0] v, int k); v[k +: 2]++; return v; endfunction
endpackage
class ic;
  logic [7:0] r; int k;
  function void cm(); r[k +: 2]++; --r[k -: 3]; r[3:0]++; endfunction
endclass
interface ifc(input logic clk, input logic [2:0] k); logic [7:0] q; always_ff @(posedge clk) q[k +: 2] -= 1; always_ff @(posedge clk) q[k -: 2]++; endinterface
module top(input logic clk, input logic [2:0] k, output logic [7:0] o, o2);
  ifc u(clk, k);
  always_ff @(posedge clk) begin o <= ip::pf(o, k); o2[3:0]++; ++o2[k +: 2]; end
endmodule
