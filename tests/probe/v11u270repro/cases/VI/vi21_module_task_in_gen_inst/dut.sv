// § insideSetParamFoldKeepsPa270
module sub #(parameter int P = 1) (input int w, output logic o);
  localparam int L = P + 1;
  task automatic t(input int x, output logic y); y = x inside {L, 9}; endtask
  always_comb t(w, o);
endmodule
module top (input int w, output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    sub #(.P(i)) s (.w(w), .o(o[i]));
  end
endmodule
