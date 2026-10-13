// § nestedDeepInstStub307
module outer #(parameter int P = 1) (input logic a, output logic y);
  module inner (input logic i, output logic o); assign o = ~i; endmodule
  case (P)
    0: begin : g0 assign y = a; end
    default: begin : gd
      inner u_in (.i(a), .o(y));
    end
  endcase
endmodule
module dut (input logic a, output logic y);
  outer u1 (.a(a), .y(y));
endmodule
