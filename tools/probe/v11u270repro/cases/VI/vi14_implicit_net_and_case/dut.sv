// § insideSetParamFoldKeepsPa270
module top #(parameter int P = 2) (input int w, output logic o);
  localparam int Q = 3;
  assign n = w inside {P, Q};
  always_comb begin
    case (w) inside
      P, Q: o = n;
      [Q:10]: o = 0;
      default: o = 1;
    endcase
  end
endmodule
