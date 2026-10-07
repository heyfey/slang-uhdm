// § leftoverTsCopyPerElabUse272
// generate loops bounded by the parameter with continuous assignments one and two levels down
package pk;
  typedef struct packed { int unsigned a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam in_t UU = '{a: 11, b: 22};
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter pk::c_t P = pk::C) (input logic [15:0] i, output logic [15:0] o);
  for (genvar a = 0; a < P.u.a - 9; a++) begin : g1
    assign o[a] = i[a];
    for (genvar b = 0; b < 2; b++) begin : g2
      assign o[8 + a*2 + b] = i[P.u.b - 20 + b];
    end
  end
  assign o[7:2] = '0;
endmodule
module dut(input logic [15:0] i, output logic [15:0] o); kid k0 (.i(i), .o(o)); endmodule
