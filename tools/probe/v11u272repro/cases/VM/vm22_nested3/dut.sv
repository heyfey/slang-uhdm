// § leftoverTsCopyPerElabUse272
// (no continuous-assignment read of the parameter) three nested struct levels
package pk;
  typedef struct packed { logic [3:0] x; logic [3:0] y; } l3_t;
  typedef struct packed { l3_t m; logic [7:0] n; } l2_t;
  typedef struct packed { l2_t k; logic [15:0] d; } c_t;
  localparam l3_t L3 = '{x: 4'd1, y: 4'd2};
  function automatic c_t mk();
    c_t c; c.k.m = L3; c.k.n = 8'd9; c.d = 16'd77; return c;
  endfunction
  localparam c_t C = mk();
endpackage
module kid #(parameter pk::c_t P = pk::C) (output logic [15:0] o);
  localparam int unsigned RD1 = P.d + P.k.m.x;
  assign o = '0;
endmodule
module dut(output logic [15:0] o);
  kid k0 (.o(o));
endmodule
