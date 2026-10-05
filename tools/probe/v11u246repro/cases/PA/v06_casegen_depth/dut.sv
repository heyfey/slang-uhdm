// § callArgParamCopyOwnTs246
module sub #(parameter int N = 4, parameter int K = 1) (output logic [N-1:0][15:0] o);
  function automatic bit [N-1:0][15:0] f(int n);
    bit [N-1:0][15:0] r;
    for (int i = 0; i < n; i++) r[i] = 16'(i);
    return r;
  endfunction
  case (K)
    1: begin : g1
      for (genvar j = 0; j < 1; j++) begin : g2
        localparam bit [N-1:0][15:0] L = f(N);
        assign o = L;
      end
    end
    default: begin : gd
      assign o = '0;
    end
  endcase
endmodule
module top(output logic [3:0][15:0] o);
  sub #(.N(4)) u(.o(o));
endmodule
