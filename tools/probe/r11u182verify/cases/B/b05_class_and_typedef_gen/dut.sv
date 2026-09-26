// § boundLitWrittenDigits172
package p;
  class c;
    logic [07:0] m;
    function new();
      m = 8'd1;
    endfunction
  endclass
endpackage
module dut (input logic [7:0] a, output logic [7:0] o);
  typedef logic [007:0] t_t;
  if (1) begin : g
    typedef logic [07:000] u_t;
    u_t w;
    assign w = a;
    assign o = t_t'(w);
  end
endmodule
