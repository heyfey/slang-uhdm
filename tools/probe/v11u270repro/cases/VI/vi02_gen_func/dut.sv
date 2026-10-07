// § insideSetParamFoldKeepsPa270
package up;
  parameter int A = 1;
  parameter int B = 2;
endpackage
module top (input int w, output logic o);
  import up::*;
  if (1) begin : g
    localparam int A = 7;
    function automatic logic f(int x);
      return x inside {A, B};
    endfunction
    assign o = f(w);
  end
endmodule
