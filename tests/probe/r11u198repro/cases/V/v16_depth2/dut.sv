// § callArgVarSelStamp198
module mid (input logic [1:0][3:0] p, output logic y);
  function automatic logic f(logic x); return x; endfunction
  for (genvar i = 0; i < 1; i++) begin : gl
    assign y = f(p[i][1]);
  end
  assign yy = f(p[1][2]);
endmodule
module top (input logic [1:0][3:0] p, output logic y);
  mid u (.p(p), .y(y));
endmodule
